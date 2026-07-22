from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

# Doctor Schemas
class DoctorBase(BaseModel):
    name: str
    email: str
    medical_license: str

class DoctorCreate(DoctorBase):
    password: str

class DoctorLogin(BaseModel):
    email: str
    password: str

class DoctorUpdate(BaseModel):
    name: str
    email: str
    phone: Optional[str] = None
    clinic: Optional[str] = None

class DoctorResponse(DoctorBase):
    id: int
    phone: Optional[str] = None
    clinic: Optional[str] = None

    class Config:
        from_attributes = True

# Patient Schemas
class PatientBase(BaseModel):
    name: str
    age: int
    gender: str
    guardian: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None

class PatientCreate(PatientBase):
    id: str # e.g. P-2026-0001

class PatientResponse(PatientBase):
    id: str
    last_visit: Optional[str] = None
    active_cases: int = 0

    class Config:
        from_attributes = True

# Case & Analysis Schemas
class CaseBase(BaseModel):
    tooth_number: int
    tooth_name: Optional[str] = None
    clinical_notes: Optional[str] = None

class CaseCreate(CaseBase):
    patient_id: str

class CaseAnalysisResponse(BaseModel):
    case_id: int
    patient_id: str
    tooth_number: int
    tooth_name: str
    resorption_type: str        # Normal, Physiological, Pathological
    severity: str               # None, Mild, Moderate, Severe
    affected_region: str        # Apical Third, Middle Third, Coronal Third
    affected_percentage: float  # e.g., 40.0
    clinical_implications: List[str]
    treatment_plan: List[str]
    warning_signs: List[str]
    radiograph_url: str         # URL to original image
    processed_url: str          # URL to visual explanation heatmap overlay
    created_at: datetime

    class Config:
        from_attributes = True

class PatientDetailWithCases(PatientResponse):
    cases: List[CaseAnalysisResponse] = []

    class Config:
        from_attributes = True
