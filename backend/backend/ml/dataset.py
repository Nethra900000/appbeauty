import os
import cv2
import numpy as np
import torch
from torch.utils.data import Dataset
from PIL import Image

class SyntheticToothRadiographGenerator:
    """
    Generates synthetic 2D dental radiographs of primary teeth to simulate root resorption.
    - Normal: Healthy primary tooth with full root length.
    - Physiological Resorption: Evenly shortened roots, simulating natural shedding.
    - Pathological Resorption: Asymmetric, irregular/ragged root margins, simulating inflammatory or replacement resorption.
    """
    def __init__(self, image_size=(224, 224)):
        self.image_size = image_size

    def generate_image(self, resorption_type: int, severity: int, resorption_pct: float):
        """
        Generates a grayscale synthetic radiograph image.
        - resorption_type: 0 = Normal, 1 = Physiological, 2 = Pathological
        - severity: 0 = None, 1 = Mild, 2 = Moderate, 3 = Severe
        - resorption_pct: float from 0.0 to 1.0
        """
        # Create base dark background (radiolucent bone tissue)
        img = np.zeros(self.image_size, dtype=np.uint8)
        
        # 1. Generate bone background texture (trabecular-like patterns)
        noise = np.random.normal(100, 15, self.image_size).astype(np.uint8)
        img = cv2.addWeighted(img, 0.5, noise, 0.5, 0)
        img = cv2.GaussianBlur(img, (5, 5), 0)
        
        # Add some bone trabecular lines (subtle structures)
        for _ in range(15):
            x1, y1 = np.random.randint(0, self.image_size[1], 2)
            x2, y2 = x1 + np.random.randint(-15, 15), y1 + np.random.randint(-15, 15)
            color = np.random.randint(110, 140)
            thickness = np.random.randint(1, 3)
            cv2.line(img, (x1, y1), (x2, y2), color, thickness)
        img = cv2.GaussianBlur(img, (3, 3), 0)

        # 2. Draw Successor Tooth Bud (underneath the primary tooth)
        # Represents the permanent tooth growing underneath.
        # It's highly radiopaque (brighter) at the bottom.
        bud_center = (self.image_size[1] // 2, int(self.image_size[0] * 0.85))
        bud_axes = (35, 20)
        cv2.ellipse(img, bud_center, bud_axes, 0, 0, 360, 130, -1)
        # Add inner enamel cap outline (brighter)
        cv2.ellipse(img, bud_center, (25, 12), 0, 0, 360, 170, 2)

        # 3. Draw Primary Tooth (Crown and Roots)
        # Tooth is radiopaque (lighter gray, 160-220 brightness)
        tooth_mask = np.zeros(self.image_size, dtype=np.uint8)
        
        crown_center = (self.image_size[1] // 2, int(self.image_size[0] * 0.25))
        
        # Draw Crown: bulbous primary molar crown
        crown_pts = np.array([
            [crown_center[0] - 40, crown_center[1] - 20], # Top Left
            [crown_center[0] - 25, crown_center[1] - 35], # Top arch
            [crown_center[0] + 25, crown_center[1] - 35], # Top arch
            [crown_center[0] + 40, crown_center[1] - 20], # Top Right
            [crown_center[0] + 35, crown_center[1] + 15], # Bottom Right
            [crown_center[0] - 35, crown_center[1] + 15]  # Bottom Left
        ], dtype=np.int32)
        cv2.fillPoly(tooth_mask, [crown_pts], 180)
        
        # Pulp chamber inside crown (darker)
        pulp_pts = np.array([
            [crown_center[0] - 20, crown_center[1] - 15],
            [crown_center[0] - 10, crown_center[1] - 22],
            [crown_center[0] + 10, crown_center[1] - 22],
            [crown_center[0] + 20, crown_center[1] - 15],
            [crown_center[0] + 15, crown_center[1] + 5],
            [crown_center[0] - 15, crown_center[1] + 5]
        ], dtype=np.int32)
        cv2.fillPoly(tooth_mask, [pulp_pts], 80)

        # Draw Roots: typically two diverging roots for primary molars (mesial & distal)
        # Full root length starts around crown_center.y + 15 and extends to about y = 140.
        root_start_y = crown_center[1] + 15
        max_root_len = 80  # Max height of roots from start to apical tip
        
        # Adjust root length based on resorption percentage
        # resorption_pct ranges from 0.0 (no resorption) to 1.0 (root fully gone)
        current_root_len = max_root_len * (1.0 - resorption_pct)
        root_end_y = int(root_start_y + current_root_len)
        
        # Coordinates of root tips
        left_tip_x = int(crown_center[0] - 30 - current_root_len * 0.15)
        right_tip_x = int(crown_center[0] + 30 + current_root_len * 0.15)
        
        # Draw Left Root
        left_root_pts = np.array([
            [crown_center[0] - 35, root_start_y],  # Crown junction outer
            [crown_center[0] - 12, root_start_y],  # Crown junction inner (bifurcation)
            [left_tip_x + 5, root_end_y - 8],      # Outer curve
            [left_tip_x, root_end_y],              # Apical tip
            [left_tip_x - 6, root_end_y - 8]       # Inner curve
        ], dtype=np.int32)
        cv2.fillPoly(tooth_mask, [left_root_pts], 180)
        
        # Draw Right Root
        right_root_pts = np.array([
            [crown_center[0] + 12, root_start_y],  # Crown junction inner
            [crown_center[0] + 35, root_start_y],  # Crown junction outer
            [right_tip_x + 6, root_end_y - 8],      # Inner curve
            [right_tip_x, root_end_y],              # Apical tip
            [right_tip_x - 5, root_end_y - 8]       # Outer curve
        ], dtype=np.int32)
        cv2.fillPoly(tooth_mask, [right_root_pts], 180)

        # Draw Root Canals (thin dark lines running inside roots)
        if current_root_len > 10:
            cv2.line(tooth_mask, (crown_center[0] - 20, root_start_y), (left_tip_x, root_end_y - 5), 80, 2)
            cv2.line(tooth_mask, (crown_center[0] + 20, root_start_y), (right_tip_x, root_end_y - 5), 80, 2)

        # 4. Modify roots shape if PATHOLOGICAL resorption
        # Pathological resorption causes irregular, moth-eaten root outlines (subtractions)
        if resorption_type == 2 and resorption_pct > 0.05:
            # We subtract small circles/ellipses randomly along the root length to simulate defects
            num_defects = np.random.randint(3, 8)
            for _ in range(num_defects):
                # Random y coordinate along the root
                defect_y = np.random.randint(root_start_y + 5, root_end_y + 2)
                # Random side (left or right root)
                if np.random.rand() > 0.5:
                    # Left root region
                    defect_x = int(crown_center[0] - 25 - (defect_y - root_start_y) * 0.15)
                else:
                    # Right root region
                    defect_x = int(crown_center[0] + 25 + (defect_y - root_start_y) * 0.15)
                
                defect_r = np.random.randint(4, 10)
                # Draw dark circles to subtract tooth material
                cv2.circle(tooth_mask, (defect_x, defect_y), defect_r, 0, -1)
                # Draw bone density back in place of subtracted tooth
                cv2.circle(tooth_mask, (defect_x, defect_y), defect_r, 110, 1)

        # 5. Combine tooth and background
        # Wherever the tooth_mask is painted (>0), we overlay it on the bone background
        mask = (tooth_mask > 0).astype(np.uint8)
        img = img * (1 - mask) + tooth_mask * mask
        
        # 6. Post-processing: Add blur, noise, and intensity gradient to make it look like a real radiograph
        img = cv2.GaussianBlur(img, (3, 3), 0)
        
        # Add random sensor noise
        sensor_noise = np.random.randint(-12, 12, self.image_size)
        img = np.clip(img.astype(np.int16) + sensor_noise, 0, 255).astype(np.uint8)
        
        # Soft contrast adjustment to mimic X-ray sensor properties
        img = cv2.equalizeHist(img)
        img = cv2.GaussianBlur(img, (3, 3), 0)

        # Create annotation coordinates (where the resorption occurred)
        # This will be useful for creating the explanation heatmap or bounding box
        affected_bbox = [0, 0, 0, 0]
        if resorption_pct > 0:
            # Apical third is from root_end_y - current_root_len/3 to root_end_y
            affected_bbox = [
                max(0, int(crown_center[0] - 50)),
                max(0, int(root_end_y - current_root_len * 0.33)),
                min(self.image_size[1], int(crown_center[0] + 50)),
                min(self.image_size[0], int(root_end_y + 5))
            ]

        return img, affected_bbox


class RootResorptionDataset(Dataset):
    """
    PyTorch Dataset wrapper for synthetic root resorption radiographs.
    Generates training samples on-the-fly or uses pre-generated files.
    """
    def __init__(self, size=200, transform=None):
        self.size = size
        self.transform = transform
        self.generator = SyntheticToothRadiographGenerator()
        
        # Pre-decide the parameters to keep dataset consistent during an epoch
        self.samples = []
        for _ in range(size):
            # 0: Normal (resorption_pct = 0.0)
            # 1: Physiological (resorption_pct > 0.0)
            # 2: Pathological (resorption_pct > 0.0)
            r_type = np.random.choice([0, 1, 2], p=[0.25, 0.4, 0.35])
            
            if r_type == 0:
                pct = 0.0
                sev = 0
            else:
                pct = np.random.uniform(0.05, 0.85)
                if pct < 0.33:
                    sev = 1 # Mild
                elif pct < 0.66:
                    sev = 2 # Moderate
                else:
                    sev = 3 # Severe
            
            self.samples.append((int(r_type), int(sev), float(pct)))

    def __len__(self):
        return self.size

    def __getitem__(self, idx):
        r_type, sev, pct = self.samples[idx]
        img, bbox = self.generator.generate_image(r_type, sev, pct)
        
        # Convert grayscale image to 3 channels for pre-trained CNN backbones
        img_rgb = cv2.cvtColor(img, cv2.COLOR_GRAY2RGB)
        
        if self.transform:
            # Assuming Albumentations or Torchvision
            img_pil = Image.fromarray(img_rgb)
            img_tensor = self.transform(img_pil)
        else:
            # Standard PyTorch normalization
            img_tensor = torch.tensor(img_rgb, dtype=torch.float32).permute(2, 0, 1) / 255.0

        return {
            "image": img_tensor,
            "resorption_type": torch.tensor(r_type, dtype=torch.long),
            "severity": torch.tensor(sev, dtype=torch.long),
            "resorption_percentage": torch.tensor(pct, dtype=torch.float32),
            "bbox": torch.tensor(bbox, dtype=torch.float32)
        }
