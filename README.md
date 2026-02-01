# TwoBoneIKEditor3D

A simple editor tool for real-time Inverse Kinematics in Godot 4. Create and manipulate two-bone IK chains directly in the editor without entering play mode.

![IK Editor Preview](https://img.shields.io/badge/Godot-4.x-478CBF?logo=godotengine)
![License](https://img.shields.io/badge/License-MIT-blue.svg)
![Tool](https://img.shields.io/badge/Tool-Editor%20Plugin-green)

## Features

- **Editor-Only** - Works entirely in the Godot editor, no play mode required
- **Auto-Setup** - Automatically creates bone hierarchy when added to scene
- **Real-time IK** - Solves IK instantly as you move targets
- **Elbow Control** - Adjust elbow swivel rotation (0-360°)
- **Bone Length Preservation** - Maintains correct bone lengths during posing

## Quick Start

1. **Add the script to the project**
   Drag TwoBoneIKEditor3D.gd to any place in the project

2. **Add to Scene**  
   In the menu for adding a child node (Ctrl+A) Node/Node3D/BoneAttachment3D/TwoBoneIKEditor3D
   Drag 'TwoBoneIKEditor3D' node into your scene - it automatically creates Mid and Tip child nodes.
   ```
    TwoBoneIKEditor3D
    └── Mid
        └── Tip
   ```

3. **Set TwoBoneIKEditor3D properties**  
   Assign any Node3D as Target Node in the inspector
   Assign your Skeleton3D as Skeleton in the inspector
   Enable the Override Skeleton if you want to change your skeleton

4. **Set Bones**
   In all 3 nodes, select the corresponding Bone Name in the BoneAttachment3D section
   (Turn Override Skeleton off and on to return the bones to their original position.)

5. **Pose**  
   Move the target node - the IK chain updates in real-time!

6. **Elbow**
   Modify Elbow_Swivel to set the correct elbow direction.

7. **Bones Rotation** 
   You can also change the rotation of the bones in their Transform, the script will adjust

## Properties

| Property | Description |
|----------|-------------|
| **Target Node** | Node3D to follow (the hand/foot position) |
| **Skeleton** | Your Skeleton3D |
| **Mid Node** | BoneAttachment3D (elbow/knee) |
| **Tip Node** | BoneAttachment3D (hand/foot) |
| **Active** | Enable/disable IK solving |
| **Override Skeleton** | Enable it if you want to change your skeleton 
| **Auto Update** | automatically performs calculations when the parameters or position of the target change. |
| **Elbow Swivel** | Rotate elbow around the arm axis (0-360°) |

## How It Works

1. Calculates elbow position using law of cosines
2. Orients shoulder toward elbow
3. Orients elbow toward target

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

## License

MIT License - see LICENSE file for details.
