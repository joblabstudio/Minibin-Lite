
# Minibin Lite: Technical Analysis & Benefits

Minibin Lite is a lightweight system utility designed to manage the Windows Recycle Bin directly from the notification area (system tray). Unlike bulky third-party solutions, this project is focused on maximum performance and native integration.

![photo_2026-01-22_08-33-15](https://github.com/user-attachments/assets/d2e58b56-0336-4de1-860b-3f4b4306277f)


# Build

To create a standalone EXE file with embedded logic and a custom icon, follow these steps:

### 1. File Preparation

Ensure that the following two files are in the same folder:

-   `minibin.ps1` — The main Recycle Bin logic script.
    
-   `build.ps1` — The compiler script.
    

### 2. Compilation Process

1.  Open a terminal (PowerShell) or Visual Studio Code in the project folder.
    
2.  Run the build script using the following command:
    
    ```
    .\build.ps1
    ```
    
3.  The script will automatically:
    
    -   Read the content of `minibin.ps1`.
        
    -   Extract the Recycle Bin icon from system resources.
        
    -   Compile the C# wrapper with metadata.
        
    -   Generate the `Minibin Lite.exe` file in the same directory.
        

### 3. Usage

-   The resulting **Minibin Lite.exe** is fully portable. You can move it to any folder.
    
-   Upon execution, it creates a temporary runtime script and launches it in hidden mode.
    
-   To remove the program, simply close it via the tray (Exit) and delete the EXE file.
    

### 4. Troubleshooting

-   **Compiler Error (csc.exe not found)**: Ensure that .NET Framework is installed (standard on Windows 10/11).
    
-   **Icon Not Updating**: Windows Explorer sometimes caches icons. Try moving the file to another folder or restarting `explorer.exe`.

## 1. Key Features

-   **Dynamic Icon Updates**: The tray icon changes in real-time depending on the Recycle Bin state (empty or full).
    
-   **One-Click Access**: Open the Recycle Bin with a left mouse click and use the context menu for quick emptying.
    
-   **Background Operation**: Runs completely invisibly, without creating extra windows or processes on the taskbar.
    
-   **Embedded Logic**: All PowerShell functionality is "baked" into the binary EXE file, making the program portable and secure.
    

## 2. Structural Advantages

The program is built on a hybrid architecture:

1.  **C# Wrapper**: A compiled C# shell that ensures hidden execution and correct display of metadata (icon, version, description).
    
2.  **PowerShell Core**: Leverages the powerful Windows automation engine to interact with system APIs (Shell.Application) without requiring additional library installations.
    

## 3. Why Native is Better (Minibin Lite vs. Python/Electron)

### Resource Consumption (RAM/CPU)

-   **Python**: Requires an interpreter and often occupies 30 to 100 MB of RAM. When packaged into an EXE via `PyInstaller`, the file size reaches 15–20 MB due to the inclusion of all bundled libraries.
    
-   **Minibin Lite**: Consumes minimal memory as it uses .NET and PowerShell components already loaded in the system. The EXE size is less than 10 KB.
    

### Deployment & Zero Dependencies

-   Unlike programs written in Python or Node.js (Electron), Minibin Lite **does not require the installation of third-party runtimes**. Everything needed is already present in any modern version of Windows (7, 10, 11).
