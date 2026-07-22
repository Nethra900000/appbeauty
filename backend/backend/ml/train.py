import os
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
from torchvision import transforms

from .dataset import RootResorptionDataset
from .model import MultiTaskRootResorptionCNN

def train_model(epochs=15, batch_size=32, model_save_path="model.pth"):
    # Set device (use GPU if available, else CPU)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Training on device: {device}")
    
    # 1. Image Transformations
    # Standard normalization for images
    transform = transforms.Compose([
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    
    # Custom transform wrapper since dataset outputs tensor directly
    # We will generate dataset without PIL transformations, just standard normalizations in dataset
    # We can pass PyTorch standard normalization directly
    normalize_transform = transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])

    # 2. Datasets & Loaders
    print("Generating synthetic datasets...")
    train_dataset = RootResorptionDataset(size=600, transform=normalize_transform)
    val_dataset = RootResorptionDataset(size=150, transform=normalize_transform)
    
    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False)
    
    # 3. Model, Loss, and Optimizer
    model = MultiTaskRootResorptionCNN().to(device)
    
    criterion_type = nn.CrossEntropyLoss()
    criterion_severity = nn.CrossEntropyLoss()
    criterion_pct = nn.MSELoss()
    
    optimizer = optim.Adam(model.parameters(), lr=0.001)
    scheduler = optim.lr_scheduler.StepLR(optimizer, step_size=7, gamma=0.5)

    # 4. Training Loop
    print("Starting training loop...")
    best_val_loss = float('inf')
    
    for epoch in range(epochs):
        model.train()
        running_loss = 0.0
        running_type_correct = 0
        running_sev_correct = 0
        total_samples = 0
        
        for batch in train_loader:
            images = batch["image"].to(device)
            target_type = batch["resorption_type"].to(device)
            target_sev = batch["severity"].to(device)
            target_pct = batch["resorption_percentage"].to(device)
            
            # Zero gradients
            optimizer.zero_grad()
            
            # Forward pass
            type_logits, sev_logits, pct_pred = model(images)
            
            # Compute multi-task loss
            loss_type = criterion_type(type_logits, target_type)
            loss_sev = criterion_severity(sev_logits, target_sev)
            loss_pct = criterion_pct(pct_pred, target_pct)
            
            # Combine losses with weighting
            loss = loss_type + loss_sev + 5.0 * loss_pct
            
            # Backward pass & step
            loss.backward()
            optimizer.step()
            
            # Track training metrics
            running_loss += loss.item() * images.size(0)
            
            _, type_preds = torch.max(type_logits, 1)
            _, sev_preds = torch.max(sev_logits, 1)
            
            running_type_correct += torch.sum(type_preds == target_type).item()
            running_sev_correct += torch.sum(sev_preds == target_sev).item()
            total_samples += images.size(0)
            
        epoch_loss = running_loss / total_samples
        epoch_type_acc = running_type_correct / total_samples
        epoch_sev_acc = running_sev_correct / total_samples
        
        # Validation Phase
        model.eval()
        val_loss = 0.0
        val_type_correct = 0
        val_sev_correct = 0
        val_pct_mae = 0.0
        val_samples = 0
        
        with torch.no_grad():
            for batch in val_loader:
                images = batch["image"].to(device)
                target_type = batch["resorption_type"].to(device)
                target_sev = batch["severity"].to(device)
                target_pct = batch["resorption_percentage"].to(device)
                
                type_logits, sev_logits, pct_pred = model(images)
                
                loss_type = criterion_type(type_logits, target_type)
                loss_sev = criterion_severity(sev_logits, target_sev)
                loss_pct = criterion_pct(pct_pred, target_pct)
                
                loss = loss_type + loss_sev + 5.0 * loss_pct
                val_loss += loss.item() * images.size(0)
                
                _, type_preds = torch.max(type_logits, 1)
                _, sev_preds = torch.max(sev_logits, 1)
                
                val_type_correct += torch.sum(type_preds == target_type).item()
                val_sev_correct += torch.sum(sev_preds == target_sev).item()
                val_pct_mae += torch.sum(torch.abs(pct_pred - target_pct)).item()
                val_samples += images.size(0)
                
        val_epoch_loss = val_loss / val_samples
        val_type_acc = val_type_correct / val_samples
        val_sev_acc = val_sev_correct / val_samples
        val_mae = val_pct_mae / val_samples
        
        scheduler.step()
        
        print(f"Epoch {epoch+1}/{epochs} | "
              f"Train Loss: {epoch_loss:.4f} | Type Acc: {epoch_type_acc:.2%}, Sev Acc: {epoch_sev_acc:.2%} | "
              f"Val Loss: {val_epoch_loss:.4f} | Val Type Acc: {val_type_acc:.2%}, Val Sev Acc: {val_sev_acc:.2%}, Val Pct MAE: {val_mae:.4f}")
        
        # Save best model
        if val_epoch_loss < best_val_loss:
            best_val_loss = val_epoch_loss
            torch.save(model.state_dict(), model_save_path)
            print(f"--> Saved best model weights to {model_save_path}")
            
    print("Training Completed.")

if __name__ == "__main__":
    # Ensure current directory is backend/ml so paths resolve correctly if run directly
    os.makedirs(os.path.dirname("model.pth") if os.path.dirname("model.pth") else ".", exist_ok=True)
    train_model(epochs=15, model_save_path="model.pth")
