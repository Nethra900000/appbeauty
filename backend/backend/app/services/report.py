import os
from fpdf import FPDF
from datetime import datetime

class DentalReportPDF(FPDF):
    def header(self):
        # Draw background color band for the header
        self.set_fill_color(19, 150, 178) # Teal: #1396B2
        self.rect(0, 0, 210, 40, 'F')
        
        # Title text
        self.set_text_color(255, 255, 255)
        self.set_font('Helvetica', 'B', 20)
        self.cell(0, 10, 'ROOT RESORPTION ANALYSIS REPORT', 0, 1, 'C')
        
        # Subtitle
        self.set_font('Helvetica', 'I', 10)
        self.cell(0, 5, 'Clinical Decision-Support & Pediatric Dental Learning Tool', 0, 1, 'C')
        self.ln(10)

    def footer(self):
        # Position at 1.5 cm from bottom
        self.set_y(-15)
        self.set_font('Helvetica', 'I', 8)
        self.set_text_color(128, 128, 128)
        # Page number
        self.cell(0, 10, f'Page {self.page_no()}/{{nb}} | Generated automatically by DentAI Root Analysis App', 0, 0, 'C')

def generate_case_report(case_data: dict, patient_data: dict, output_path: str):
    """
    Generates a structured PDF report for a case.
    case_data: Dict containing case details (resorption_type, severity, percentage, etc.)
    patient_data: Dict containing patient details (name, age, gender, guardian, etc.)
    """
    pdf = DentalReportPDF()
    pdf.alias_nb_pages()
    pdf.add_page()
    pdf.ln(15) # Add space after header band
    
    # 1. Document Metadata (Date & ID)
    pdf.set_text_color(100, 110, 120)
    pdf.set_font('Helvetica', '', 10)
    current_date = datetime.now().strftime("%B %d, %Y - %I:%M %p")
    pdf.cell(100, 8, f"Report Date: {current_date}", 0, 0)
    pdf.cell(0, 8, f"Case Reference ID: CR-2026-{case_data.get('id', 'NEW')}", 0, 1, 'R')
    pdf.line(10, pdf.get_y(), 200, pdf.get_y())
    pdf.ln(5)
    
    # 2. Patient & Clinical Setup
    # Two Columns: Patient Info & Case/Tooth Info
    pdf.set_font('Helvetica', 'B', 12)
    pdf.set_text_color(15, 23, 42) # Slate-900
    pdf.cell(95, 8, "Patient Information", 0, 0)
    pdf.cell(95, 8, "Radiograph Information", 0, 1)
    
    pdf.set_font('Helvetica', '', 10)
    pdf.set_text_color(70, 80, 90)
    
    # Column 1 contents
    p_id = patient_data.get('id', 'N/A')
    p_name = patient_data.get('name', 'N/A')
    p_age = patient_data.get('age', 'N/A')
    p_gender = patient_data.get('gender', 'N/A')
    p_guardian = patient_data.get('guardian', 'N/A')
    
    # Column 2 contents
    t_num = case_data.get('tooth_number', 'N/A')
    t_name = case_data.get('tooth_name', 'N/A')
    notes = case_data.get('clinical_notes', 'None recorded.')
    
    y_start = pdf.get_y()
    
    # Left column details
    pdf.cell(95, 6, f"Patient Name: {p_name}", 0, 1)
    pdf.cell(95, 6, f"Patient ID: {p_id}", 0, 1)
    pdf.cell(95, 6, f"Age / Gender: {p_age} years old / {p_gender}", 0, 1)
    pdf.cell(95, 6, f"Guardian Name: {p_guardian}", 0, 1)
    
    y_col1 = pdf.get_y()
    
    # Right column details
    pdf.set_y(y_start)
    pdf.set_x(110)
    pdf.cell(95, 6, f"Target Tooth: Tooth {t_num} ({t_name})", 0, 1)
    pdf.set_x(110)
    pdf.cell(95, 6, f"Clinical Notes: {notes}", 0, 1)
    
    y_col2 = pdf.get_y()
    
    # Move past columns
    pdf.set_y(max(y_col1, y_col2) + 5)
    pdf.line(10, pdf.get_y(), 200, pdf.get_y())
    pdf.ln(5)
    
    # 3. AI Analysis Results Section
    pdf.set_font('Helvetica', 'B', 14)
    pdf.set_text_color(19, 150, 178) # Teal
    pdf.cell(0, 8, "Artificial Intelligence Radiographic Evaluation", 0, 1)
    pdf.ln(2)
    
    # Drawing color coding values
    res_type = case_data.get('resorption_type', 'Normal')
    severity = case_data.get('severity', 'None')
    percentage = case_data.get('affected_percentage', 0.0)
    region = case_data.get('affected_region', 'None')
    
    # Background card block for results
    pdf.set_fill_color(245, 247, 250) # Light grey card background
    pdf.rect(10, pdf.get_y(), 190, 24, 'F')
    
    pdf.set_font('Helvetica', 'B', 11)
    pdf.set_text_color(15, 23, 42)
    
    pdf.set_y(pdf.get_y() + 2)
    pdf.set_x(15)
    pdf.cell(60, 6, "Resorption Type:", 0, 0)
    pdf.cell(60, 6, "Severity Classification:", 0, 0)
    pdf.cell(60, 6, "Affected Percentage:", 0, 1)
    
    pdf.set_font('Helvetica', '', 11)
    # Type color
    if res_type == "Pathological":
        pdf.set_text_color(200, 0, 0) # Red
    elif res_type == "Physiological":
        pdf.set_text_color(220, 110, 0) # Orange
    else:
        pdf.set_text_color(0, 150, 0) # Green
        
    pdf.set_x(15)
    pdf.cell(60, 6, res_type, 0, 0)
    
    # Severity color
    if severity == "Severe":
        pdf.set_text_color(200, 0, 0)
    elif severity == "Moderate":
        pdf.set_text_color(220, 110, 0)
    else:
        pdf.set_text_color(15, 23, 42)
        
    pdf.cell(60, 6, f"{severity} ({region})", 0, 0)
    
    pdf.set_text_color(15, 23, 42)
    pdf.cell(60, 6, f"{percentage}%", 0, 1)
    
    pdf.set_y(pdf.get_y() + 8) # Move past card block
    pdf.ln(2)
    
    # 4. Images Embed Layout (Side by Side)
    # Each image drawn with width ~80mm
    original_img = case_data.get('radiograph_path')
    processed_img = case_data.get('processed_path')
    
    if original_img and processed_img and os.path.exists(original_img) and os.path.exists(processed_img):
        pdf.set_font('Helvetica', 'B', 10)
        pdf.set_text_color(100, 110, 120)
        pdf.cell(95, 6, "Uploaded Radiograph", 0, 0, 'C')
        pdf.cell(95, 6, "AI Resorption Overlay", 0, 1, 'C')
        
        y_img = pdf.get_y()
        try:
            # Place images side by side
            pdf.image(original_img, x=15, y=y_img, w=80, h=60)
            pdf.image(processed_img, x=115, y=y_img, w=80, h=60)
            pdf.ln(62) # Advance cursor past image heights
        except Exception as e:
            pdf.set_text_color(200, 0, 0)
            pdf.cell(0, 10, f"Error embedding images: {e}", 0, 1)
    else:
        pdf.set_font('Helvetica', 'I', 10)
        pdf.set_text_color(128, 128, 128)
        pdf.cell(0, 10, "Image files not available for embedding.", 0, 1, 'C')
        pdf.ln(5)

    pdf.line(10, pdf.get_y(), 200, pdf.get_y())
    pdf.ln(5)
    
    # 5. Clinical Implications, Plans and Warnings
    # Retrieve clinical text lists
    implications = case_data.get('clinical_implications', [])
    plan = case_data.get('treatment_plan', [])
    warnings = case_data.get('warning_signs', [])
    
    # Check if we need to add a page to avoid spill-over formatting problems
    if pdf.get_y() > 210:
        pdf.add_page()
        pdf.ln(15)
        
    pdf.set_font('Helvetica', 'B', 12)
    pdf.set_text_color(19, 150, 178) # Teal
    pdf.cell(0, 6, "Clinical Interpretation & Guidelines", 0, 1)
    
    pdf.set_font('Helvetica', '', 10)
    pdf.set_text_color(70, 80, 90)
    
    pdf.set_font('Helvetica', 'B', 10)
    pdf.cell(0, 5, "Implications:", 0, 1)
    pdf.set_font('Helvetica', '', 10)
    for imp in implications:
        pdf.cell(5, 5, "-", 0, 0)
        pdf.multi_cell(0, 5, imp)
    pdf.ln(2)
        
    pdf.set_font('Helvetica', 'B', 10)
    pdf.cell(0, 5, "Intervention & Treatment Actions:", 0, 1)
    pdf.set_font('Helvetica', '', 10)
    for step in plan:
        pdf.cell(5, 5, "-", 0, 0)
        pdf.multi_cell(0, 5, step)
    pdf.ln(2)
        
    pdf.set_font('Helvetica', 'B', 10)
    pdf.set_text_color(180, 80, 0) # Warn Color
    pdf.cell(0, 5, "Warning Signs to Monitor:", 0, 1)
    pdf.set_font('Helvetica', '', 10)
    pdf.set_text_color(70, 80, 90)
    for sign in warnings:
        pdf.cell(5, 5, "-", 0, 0)
        pdf.multi_cell(0, 5, sign)
        
    # Signature Section
    pdf.ln(8)
    if pdf.get_y() > 250:
        pdf.add_page()
        pdf.ln(15)
        
    pdf.ln(5)
    pdf.set_text_color(128, 128, 128)
    pdf.cell(100, 10, "_____________________________", 0, 0, 'L')
    pdf.cell(0, 10, "_____________________________", 0, 1, 'R')
    pdf.cell(100, 5, "Reviewing Clinician Signature", 0, 0, 'L')
    pdf.cell(0, 5, "Clinician Medical License No.", 0, 1, 'R')

    # Save to path
    pdf.output(output_path)
    print(f"Report PDF generated at {output_path}")
