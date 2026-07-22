from datetime import datetime
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from app.core.config import settings

# Create SQLAlchemy engine
# If SQLite is used, connect_args={"check_same_thread": False} is required
connect_args = {}
if settings.DATABASE_URL.startswith("sqlite"):
    connect_args = {"check_same_thread": False}

engine = create_engine(settings.DATABASE_URL, connect_args=connect_args)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class Doctor(Base):
    __tablename__ = "doctors"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    medical_license = Column(String(50), unique=True, index=True)
    email = Column(String(100), unique=True, index=True, nullable=False)
    password = Column(String(100), nullable=False)
    phone = Column(String(20), nullable=True)
    clinic = Column(String(100), nullable=True)
    
    cases = relationship("Case", back_populates="doctor")

class Patient(Base):
    __tablename__ = "patients"
    
    id = Column(String(50), primary_key=True, index=True) # e.g. P-2026-0001
    name = Column(String(100), nullable=False)
    age = Column(Integer, nullable=False)
    gender = Column(String(20), nullable=False)
    last_visit = Column(String(50), nullable=True)
    guardian = Column(String(100), nullable=True)
    phone = Column(String(20), nullable=True)
    email = Column(String(100), nullable=True)
    active_cases = Column(Integer, default=0)
    
    cases = relationship("Case", back_populates="patient", cascade="all, delete-orphan")

class Case(Base):
    __tablename__ = "cases"
    
    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(String(50), ForeignKey("patients.id", ondelete="CASCADE"), nullable=False)
    doctor_id = Column(Integer, ForeignKey("doctors.id"), nullable=True)
    
    tooth_number = Column(Integer, nullable=False) # FDI notation, e.g. 55, 65
    tooth_name = Column(String(100), nullable=True) # e.g. Upper Right Second Molar
    clinical_notes = Column(String(500), nullable=True)
    
    radiograph_path = Column(String(255), nullable=False) # uploaded scan
    processed_path = Column(String(255), nullable=True)   # scan with heatmap overlay
    
    resorption_type = Column(String(50), nullable=False)   # Normal, Physiological, Pathological
    severity = Column(String(50), nullable=False)          # None, Mild, Moderate, Severe
    affected_region = Column(String(100), nullable=True)   # Apical Third, Middle Third, Coronal Third
    affected_percentage = Column(Float, default=0.0)       # e.g. 40.0%
    
    # Store JSON-like string arrays
    treatment_plan = Column(String(1000), nullable=True)   # Action items serialized as string or JSON
    risk_factors = Column(String(1000), nullable=True)      # Warning signs / risk indicators
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    patient = relationship("Patient", back_populates="cases")
    doctor = relationship("Doctor", back_populates="cases")

# Helper to create tables
def init_db():
    Base.metadata.create_all(bind=engine)

# Dependency to get db session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
