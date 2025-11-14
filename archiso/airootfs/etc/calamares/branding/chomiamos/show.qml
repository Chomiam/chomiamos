import QtQuick 2.0
import calamares.slideshow 1.0

Presentation {
    id: presentation

    function nextSlide() {
        console.log("At activatedInCalamares(" + presentation.activatedInCalamares + ") count(" + presentation.currentSlide + "/" + count + ").");
        presentation.currentSlide = (presentation.currentSlide + 1) % count;
    }

    Timer {
        id: advanceTimer
        interval: 10000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: nextSlide()
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#2c3e50"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    text: "Bienvenue sur ChomiamOS"
                    font.pixelSize: 32
                    font.bold: true
                    color: "#ffffff"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Une distribution Arch Linux personnalisée avec KDE Plasma"
                    font.pixelSize: 18
                    color: "#ecf0f1"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#34495e"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    text: "Installation en cours..."
                    font.pixelSize: 28
                    font.bold: true
                    color: "#ffffff"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Votre système sera prêt dans quelques minutes"
                    font.pixelSize: 18
                    color: "#ecf0f1"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#2c3e50"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    text: "KDE Plasma Desktop"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#ffffff"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Un environnement de bureau moderne et personnalisable"
                    font.pixelSize: 18
                    color: "#ecf0f1"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
