from py2exe import freeze
from glob import glob

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

pyzmq_libs = "c:\\Python38\\Lib\\site-packages\\pyzmq.libs\\"
libsodium = glob(pyzmq_libs + "libsodium*.dll")[0]
libzmq = glob(pyzmq_libs + "libzmq*.dll")[0]

freeze(
    windows=[{"script": "exec.py"}, {"script": "pyside2-uic.py"}],
    data_files=[
        (
            "",
            [
                "c:\\Python38\\Lib\\site-packages\\PySide2\\Qt5Designer.dll",
                "c:\\Python38\\Lib\\site-packages\\PySide2\\Qt5DesignerComponents.dll",
                "c:\\Python38\\Lib\\site-packages\\PySide2\\designer.exe",
                "c:\\Python38\\Lib\\site-packages\\PySide2\\uic.exe",
                "c:\\Python38\\Lib\\site-packages\\usb1\\libusb-1.0.dll",
                libsodium,
                libzmq,
            ],
        ),
        (
            "platforms",
            [
                "c:\\Python38\\Lib\\site-packages\\PySide2\\plugins\\platforms\\qwindows.dll"
            ],
        ),
        (
            "styles",
            [
                "c:\\Python38\\Lib\\site-packages\\PySide2\\plugins\\styles\\qwindowsvistastyle.dll"
            ],
        ),
    ],
    options={"includes": includes, "bundle_files": 3, "compressed": True},
)
