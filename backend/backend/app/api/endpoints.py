import os
import json
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, Query
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from typing import List, Optional

from app.models import database as db
from app.schemas import schemas
from app.services.ai_model import AIAnalysisService
from app.services.report import generate_case_report
from app.core.config import settings

router = APIRouter()
ai_service = AIAnalysisService()

# ----------------------------------------
# AUTHENTICATION ENDPOINTS (Form-based to align with mobile clients)
# ----------------------------------------

@router.post("/login")
def login(
    email: str = Form(...),
    password: str = Form(...),
    session: Session = Depends(db.get_db)
):
    doctor = session.query(db.Doctor).filter(db.Doctor.email == email, db.Doctor.password == password).first()
    if doctor:
        return {
            "success": True,
            "message": "Login Successful",
            "id": doctor.id,
            "name": doctor.name,
            "email": doctor.email,
            "medical_license": doctor.medical_license,
            "phone": doctor.phone or "",
            "clinic": doctor.clinic or ""
        }
    return {
        "success": False,
        "message": "Invalid Email or Password"
    }

@router.post("/signup")
def signup(
    name: str = Form(...),
    license: str = Form(...),
    email: str = Form(...),
    password: str = Form(...),
    session: Session = Depends(db.get_db)
):
    # Check if doctor already exists
    existing = session.query(db.Doctor).filter(db.Doctor.email == email).first()
    if existing:
        return {
            "success": False,
            "message": "Email already exists"
        }
        
    existing_license = session.query(db.Doctor).filter(db.Doctor.medical_license == license).first()
    if existing_license:
        return {
            "success": False,
            "message": "Medical license number already registered"
        }

    new_doctor = db.Doctor(
        name=name,
        medical_license=license,
        email=email,
        password=password,
        phone="",
        clinic=""
    )
    session.add(new_doctor)
    session.commit()
    session.refresh(new_doctor)

    return {
        "success": True,
        "message": "Account Created Successfully",
        "id": new_doctor.id
    }

@router.post("/fetch_profile")
def fetch_profile(
    id: int = Form(...),
    session: Session = Depends(db.get_db)
):
    doctor = session.query(db.Doctor).filter(db.Doctor.id == id).first()
    if doctor:
        return {
            "success": True,
            "name": doctor.name,
            "email": doctor.email,
            "phone": doctor.phone or "",
            "clinic": doctor.clinic or "",
            "medical_license": doctor.medical_license
        }
    return {
        "success": False,
        "message": "Doctor not found"
    }

@router.post("/update_profile")
def update_profile(
    id: int = Form(...),
    name: str = Form(...),
    email: str = Form(...),
    phone: str = Form(...),
    clinic: str = Form(...),
    session: Session = Depends(db.get_db)
):
    doctor = session.query(db.Doctor).filter(db.Doctor.id == id).first()
    if not doctor:
        return {
            "success": False,
            "message": "Doctor not found"
        }
        
    doctor.name = name
    doctor.email = email
    doctor.phone = phone
    doctor.clinic = clinic
    session.commit()

    return {
        "success": True,
        "message": "Profile Updated Successfully"
    }

# ----------------------------------------
# PATIENT MANAGEMENT ENDPOINTS
# ----------------------------------------

@router.post("/patients", response_model=schemas.PatientResponse)
def create_patient(
    patient: schemas.PatientCreate,
    session: Session = Depends(db.get_db)
):
    # Check if patient exists
    existing = session.query(db.Patient).filter(db.Patient.id == patient.id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Patient with this ID already exists")
        
    db_patient = db.Patient(
        id=patient.id,
        name=patient.name,
        age=patient.age,
        gender=patient.gender,
        guardian=patient.guardian,
        phone=patient.phone,
        email=patient.email,
        last_visit=datetime.now().strftime("%b %d, %Y"),
        active_cases=0
    )
    session.add(db_patient)
    session.commit()
    session.refresh(db_patient)
    return db_patient

@router.get("/patients", response_model=List[schemas.PatientResponse])
def get_patients(
    search: Optional[str] = Query(None, description="Search by name or ID"),
    session: Session = Depends(db.get_db)
):
    query = session.query(db.Patient)
    if search:
        query = query.filter(
            (db.Patient.name.ilike(f"%{search}%")) | 
            (db.Patient.id.ilike(f"%{search}%"))
        )
    return query.order_by(db.Patient.name).all()

@router.get("/patients/{patient_id}", response_model=schemas.PatientDetailWithCases)
def get_patient_details(
    patient_id: str,
    session: Session = Depends(db.get_db)
):
    patient = session.query(db.Patient).filter(db.Patient.id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
        
    # Build list of cases with correct URL pathways
    cases_response = []
    for case in patient.cases:
        cases_response.append(format_case_response(case))
        
    patient_detail = schemas.PatientDetailWithCases.from_orm(patient)
    patient_detail.cases = cases_response
    return patient_detail


# ----------------------------------------
# ROOT RESORPTION ANALYSIS ENDPOINTS
# ----------------------------------------

@router.post("/cases/analyze")
async def analyze_radiograph(
    patient_id: str = Form(...),
    tooth_number: int = Form(...),
    tooth_name: Optional[str] = Form(None),
    clinical_notes: Optional[str] = Form(None),
    doctor_id: Optional[int] = Form(None),
    file: UploadFile = File(...),
    session: Session = Depends(db.get_db)
):
    # 1. Verify patient exists
    patient = session.query(db.Patient).filter(db.Patient.id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
        
    # 2. Save uploaded original scan file
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    clean_filename = f"{patient_id}_{tooth_number}_{timestamp}_{file.filename}"
    original_path = os.path.join(settings.UPLOAD_DIR, clean_filename)
    
    with open(original_path, "wb") as buffer:
        content = await file.read()
        buffer.write(content)
        
    # 3. Trigger AI Model inference
    try:
        analysis_result = ai_service.run_analysis(original_path, clean_filename)
    except Exception as e:
        # Clean up file on failure
        if os.path.exists(original_path):
            os.remove(original_path)
        raise HTTPException(status_code=500, detail=f"AI model execution error: {str(e)}")

    # 4. Create and save new Case
    new_case = db.Case(
        patient_id=patient_id,
        doctor_id=doctor_id,
        tooth_number=tooth_number,
        tooth_name=tooth_name or get_default_tooth_name(tooth_number),
        clinical_notes=clinical_notes,
        radiograph_path=original_path,
        processed_path=analysis_result["processed_path"],
        resorption_type=analysis_result["resorption_type"],
        severity=analysis_result["severity"],
        affected_region=analysis_result["affected_region"],
        affected_percentage=analysis_result["affected_percentage"],
        treatment_plan=json.dumps(analysis_result["treatment_plan"]),
        risk_factors=json.dumps(analysis_result["warning_signs"])
    )
    
    session.add(new_case)
    
    # 5. Update patient status
    patient.last_visit = datetime.now().strftime("%b %d, %Y")
    if analysis_result["resorption_type"] != "Normal":
        patient.active_cases += 1
        
    session.commit()
    session.refresh(new_case)
    
    # 6. Format and return response
    return format_case_response(new_case)

@router.get("/cases/{case_id}/report")
def get_pdf_report(
    case_id: int,
    session: Session = Depends(db.get_db)
):
    case = session.query(db.Case).filter(db.Case.id == case_id).first()
    if not case:
        raise HTTPException(status_code=404, detail="Case record not found")
        
    # Gather patient details
    patient = case.patient
    patient_data = {
        "id": patient.id,
        "name": patient.name,
        "age": patient.age,
        "gender": patient.gender,
        "guardian": patient.guardian or "N/A"
    }
    
    # Format case data for report generator
    case_data = {
        "id": case.id,
        "tooth_number": case.tooth_number,
        "tooth_name": case.tooth_name,
        "clinical_notes": case.clinical_notes or "None",
        "radiograph_path": case.radiograph_path,
        "processed_path": case.processed_path,
        "resorption_type": case.resorption_type,
        "severity": case.severity,
        "affected_percentage": case.affected_percentage,
        "affected_region": case.affected_region,
        "clinical_implications": ai_service._get_clinical_details(case.resorption_type, case.severity, case.affected_region, case.affected_percentage/100.0)[0],
        "treatment_plan": json.loads(case.treatment_plan) if case.treatment_plan else [],
        "warning_signs": json.loads(case.risk_factors) if case.risk_factors else []
    }
    
    # Generate PDF name
    report_filename = f"report_case_{case.id}_{case.patient_id}.pdf"
    report_path = os.path.join(settings.REPORTS_DIR, report_filename)
    
    generate_case_report(case_data, patient_data, report_path)
    
    if os.path.exists(report_path):
        return FileResponse(
            path=report_path,
            filename=report_filename,
            media_type="application/pdf"
        )
    raise HTTPException(status_code=500, detail="Failed to generate PDF file on server.")


# ----------------------------------------
# HELPER FUNCTIONS
# ----------------------------------------

def get_default_tooth_name(tooth_number: int) -> str:
    """Returns FDI nomenclature standard primary molar names."""
    # FDI naming for primary dentition (51-55, 61-65, 71-75, 81-85)
    names = {
        55: "Primary Upper Right Second Molar",
        54: "Primary Upper Right First Molar",
        53: "Primary Upper Right Canine",
        52: "Primary Upper Right Lateral Incisor",
        51: "Primary Upper Right Central Incisor",
        61: "Primary Upper Left Central Incisor",
        62: "Primary Upper Left Lateral Incisor",
        63: "Primary Upper Left Canine",
        64: "Primary Upper Left First Molar",
        65: "Primary Upper Left Second Molar",
        75: "Primary Lower Left Second Molar",
        74: "Primary Lower Left First Molar",
        73: "Primary Lower Left Canine",
        72: "Primary Lower Left Lateral Incisor",
        71: "Primary Lower Left Central Incisor",
        81: "Primary Lower Right Central Incisor",
        82: "Primary Lower Right Lateral Incisor",
        83: "Primary Lower Right Canine",
        84: "Primary Lower Right First Molar",
        85: "Primary Lower Right Second Molar"
    }
    return names.get(tooth_number, f"Primary Tooth {tooth_number}")

def format_case_response(case: db.Case) -> dict:
    """Helper to convert db.Case to Response dict with deserialized JSON lists and static URLs."""
    # Deserializing string arrays
    t_plan = json.loads(case.treatment_plan) if case.treatment_plan else []
    w_signs = json.loads(case.risk_factors) if case.risk_factors else []
    
    # Simple rule-based retrieval of implications to keep schema complete
    ai_service_local = AIAnalysisService()
    implications, _, _ = ai_service_local._get_clinical_details(
        case.resorption_type, 
        case.severity, 
        case.affected_region, 
        case.affected_percentage / 100.0
    )
    
    # We serve uploaded files through FastAPI static files middleware on "/files" route
    radiograph_url = f"/files/uploads/{os.path.basename(case.radiograph_path)}"
    processed_url = f"/files/processed/{os.path.basename(case.processed_path)}" if case.processed_path else ""

    return {
        "case_id": case.id,
        "patient_id": case.patient_id,
        "tooth_number": case.tooth_number,
        "tooth_name": case.tooth_name,
        "resorption_type": case.resorption_type,
        "severity": case.severity,
        "affected_region": case.affected_region,
        "affected_percentage": case.affected_percentage,
        "clinical_implications": implications,
        "treatment_plan": t_plan,
        "warning_signs": w_signs,
        "radiograph_url": radiograph_url,
        "processed_url": processed_url,
        "created_at": case.created_at
    }
