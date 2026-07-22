import torch
import torch.nn as nn
import torch.nn.functional as F

class MultiTaskRootResorptionCNN(nn.Module):
    """
    A custom Convolutional Neural Network that performs multi-task predictions:
    1. Resorption Type (Classification: Normal=0, Physiological=1, Pathological=2)
    2. Severity Level (Classification: None=0, Mild=1, Moderate=2, Severe=3)
    3. Resorption Percentage (Regression: 0.0 - 1.0)
    """
    def __init__(self):
        super(MultiTaskRootResorptionCNN, self).__init__()
        
        # Convolutional Block 1
        self.conv1 = nn.Conv2d(3, 16, kernel_size=3, padding=1)
        self.bn1 = nn.BatchNorm2d(16)
        
        # Convolutional Block 2
        self.conv2 = nn.Conv2d(16, 32, kernel_size=3, padding=1)
        self.bn2 = nn.BatchNorm2d(32)
        
        # Convolutional Block 3
        self.conv3 = nn.Conv2d(32, 64, kernel_size=3, padding=1)
        self.bn3 = nn.BatchNorm2d(64)
        
        # Convolutional Block 4
        self.conv4 = nn.Conv2d(64, 128, kernel_size=3, padding=1)
        self.bn4 = nn.BatchNorm2d(128)
        
        self.pool = nn.MaxPool2d(2, 2)
        self.dropout = nn.Dropout(0.25)
        
        # Global average pooling to make it size-agnostic
        self.global_pool = nn.AdaptiveAvgPool2d((4, 4)) # Output: 128 * 4 * 4 = 2048 features
        
        # Shared Feature representation
        self.fc_shared = nn.Sequential(
            nn.Linear(128 * 4 * 4, 256),
            nn.ReLU(),
            nn.Dropout(0.4)
        )
        
        # Head 1: Resorption Type Classifier (3 classes)
        self.fc_type = nn.Sequential(
            nn.Linear(256, 64),
            nn.ReLU(),
            nn.Linear(64, 3)
        )
        
        # Head 2: Severity Classifier (4 classes)
        self.fc_severity = nn.Sequential(
            nn.Linear(256, 64),
            nn.ReLU(),
            nn.Linear(64, 4)
        )
        
        # Head 3: Resorption Percentage Regressor (1 continuous output, bounded between 0 and 1)
        self.fc_pct = nn.Sequential(
            nn.Linear(256, 32),
            nn.ReLU(),
            nn.Linear(32, 1),
            nn.Sigmoid()  # Restricts output to [0, 1] range
        )

    def forward(self, x):
        # x is (batch_size, 3, 224, 224)
        x = self.pool(F.relu(self.bn1(self.conv1(x))))
        x = self.pool(F.relu(self.bn2(self.conv2(x))))
        x = self.pool(F.relu(self.bn3(self.conv3(x))))
        x = self.pool(F.relu(self.bn4(self.conv4(x))))
        
        x = self.global_pool(x)
        x = x.view(x.size(0), -1) # Flatten to batch_size, 2048
        
        shared_features = self.fc_shared(x)
        
        type_logits = self.fc_type(shared_features)
        severity_logits = self.fc_severity(shared_features)
        pct_output = self.fc_pct(shared_features).squeeze(-1) # Output shape (batch_size,)
        
        return type_logits, severity_logits, pct_output
