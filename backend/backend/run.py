import os
import sys

# Ensure backend directory is in python path so imports function correctly
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "app"))

from ml.train import train_model

def main():
    ml_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "ml")
    model_path = os.path.join(ml_dir, "model.pth")
    
    # 1. Check if model weights exist
    if not os.path.exists(model_path):
        print("+" + "="*50 + "+")
        print("| Model weights (model.pth) not found.              |")
        print("| Starting automatic PyTorch model training...      |")
        print("+" + "="*50 + "+")
        
        # Train model using synthetic radiography datasets
        try:
            train_model(epochs=10, batch_size=32, model_save_path=model_path)
            print("AI Model trained successfully and weights saved.")
        except Exception as e:
            print(f"Error occurred during automatic training: {e}")
            print("System will run in simulation fallback mode.")
    else:
        print("Model weights found. Skipping training.")
        
    # 2. Launch FastAPI web server
    import uvicorn
    print("\nStarting FastAPI backend server on http://localhost:8000")
    print("API Swagger documentation available at http://localhost:8000/docs")
    
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)

if __name__ == "__main__":
    main()
