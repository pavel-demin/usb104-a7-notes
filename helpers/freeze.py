from py2exe import freeze

includes = [
    "PySide2.QtCore",
    "PySide2.QtGui",
    "PySide2.QtNetwork",
    "PySide2.QtMultimedia",
    "PySide2.QtPrintSupport",
    "PySide2.QtUiTools",
    "PySide2.QtWebSockets",
    "PySide2.QtWidgets",
    "PySide2.QtXml",
    "numpy",
    "matplotlib.backends.backend_qt5agg",
    "pyhubio",
    "zmq.backend.cython",
]

freeze(
    windows=[{"script": "exec.py"}, {"script": "pyside2-uic.py"}],
    data_files=[
        (
            "",
            [
                "c:\\Python310\\Lib\\site-packages\\PySide2\\Qt5Designer.dll",
                "c:\\Python310\\Lib\\site-packages\\PySide2\\Qt5DesignerComponents.dll",
                "c:\\Python310\\Lib\\site-packages\\PySide2\\designer.exe",
                "c:\\Python310\\Lib\\site-packages\\PySide2\\uic.exe",
                "c:\\Python310\\Lib\\site-packages\\usb1\\libusb-1.0.dll",
                "c:\\Python310\\Lib\\site-packages\\pyzmq.libs\\libsodium-ac42d648.dll",
                "c:\\Python310\\Lib\\site-packages\\pyzmq.libs\\libzmq-v141-mt-4_3_4-0a6f51ca.dll",
            ],
        ),
        (
            "platforms",
            [
                "c:\\Python310\\Lib\\site-packages\\PySide2\\plugins\\platforms\\qwindows.dll"
            ],
        ),
        (
            "styles",
            [
                "c:\\Python310\\Lib\\site-packages\\PySide2\\plugins\\styles\\qwindowsvistastyle.dll"
            ],
        ),
    ],
    options={"includes": includes, "bundle_files": 3, "compressed": True},
)
