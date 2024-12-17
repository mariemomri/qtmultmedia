import QtQuick 2.15
import QtQuick.Controls 2.15
import QtMultimedia 6.8

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "Camera App"  // Titre de la fenêtre de l'application

    // Déclaration de propriétés pour stocker les chemins d'accès des images et vidéos capturées
    property string capturedImagePath: ""
    property string videoPath: ""

    // Définition de la caméra utilisée pour capturer des images ou enregistrer des vidéos
    Camera {
        id: camera
    }

    // Configuration de l'appareil photo pour capturer des images
    ImageCapture {
        id: imageCapture
        onImageSaved: (id,filePath) => {
            console.log("Image saved to:", filePath);  // Affiche le chemin de l'image enregistrée dans la console
            capturedImagePath = filePath;  // Stocke le chemin de l'image capturée
            capturedImage.source = capturedImagePath;  // Affiche l'image capturée dans l'interface
            loadImageList();  // Recharge la liste des images capturées
        }
    }

    // Enregistreur multimédia pour enregistrer des vidéos
    MediaRecorder {
        id: mediaRecorder
        onErrorOccurred: (error, message) => {
            console.error("Recording error:", error, message);  // Affiche les erreurs d'enregistrement dans la console
        }
        onActualLocationChanged: (location) => {
            console.log("Recording saved to:", location);  // Affiche le chemin de la vidéo enregistrée
            videoPath = location;  // Stocke le chemin de la vidéo
            loadVideoList();  // Recharge la liste des vidéos enregistrées
        }
    }

    // Configuration de la session de capture pour la caméra, l'enregistreur et l'image capturée
    CaptureSession {
        id: captureSession
        camera: camera
        videoOutput: videoOutput
        imageCapture: imageCapture
        recorder: mediaRecorder
    }

    // Sortie vidéo pour afficher la vidéo capturée ou enregistrée
    VideoOutput {
        id: videoOutput
        anchors.fill: parent  // Remplir l'espace parent avec la vidéo
    }

    // Indicateur de l'état d'enregistrement (vert lorsque l'enregistrement est en cours, rouge sinon)
    Rectangle {
        id: recordingIndicator
        width: 20
        height: 20
        radius: 10
        color: mediaRecorder.recorderState === MediaRecorder.RecordingState ? "green" : "red"
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
    }

    // Barre d'outils pour contrôler la caméra, capturer des images et enregistrer des vidéos
    Row {
        spacing: 20
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50

        // Bouton pour démarrer ou arrêter la caméra
        Button {
            id: startStopCamera
            text: camera.active ? "Stop Camera" : "Start Camera"
            background: Rectangle {
                color: camera.active ? "red" : "green"  // Changer la couleur selon l'état de la caméra
                radius: 8
            }
            onClicked: {
                camera.active = !camera.active;  // Active ou désactive la caméra
            }
        }

        // Bouton pour capturer une image
        Button {
            id: captureImage
            text: "Capture Image"
            background: Rectangle {
                color: "blue"  // Couleur bleue du bouton
                radius: 8
            }
            onClicked: {
                imageCapture.captureToFile("captured_image.jpg");  // Capture l'image et l'enregistre
            }
        }

        // Bouton pour démarrer ou arrêter l'enregistrement vidéo
        Button {
            id: startStopRecording
            text: mediaRecorder.recorderState === MediaRecorder.RecordingState ? "Stop Recording" : "Start Recording"
            background: Rectangle {
                color: mediaRecorder.recorderState === MediaRecorder.RecordingState ? "orange" : "purple"
                radius: 8
            }
            onClicked: {
                if (mediaRecorder.recorderState === MediaRecorder.StoppedState) {
                    mediaRecorder.record();  // Démarre l'enregistrement
                } else if (mediaRecorder.recorderState === MediaRecorder.RecordingState) {
                    mediaRecorder.stop();  // Arrête l'enregistrement
                }
            }
        }

        // Bouton pour afficher les médias enregistrés (images et vidéos)
        Button {
            id: showMediaButton
            text: "Show Recorded Media"
            background: Rectangle {
                color: "teal"
                radius: 8
            }
            onClicked: {
                mediaDialog.open();  // Ouvre la fenêtre de dialogue pour afficher les médias
            }
        }
    }

    // Affichage de l'image capturée
    Image {
        id: capturedImage
        anchors.top: parent.top
        anchors.topMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        width: 200
        height: 150
        fillMode: Image.PreserveAspectFit  // Maintient l'aspect de l'image
    }

    // Fenêtre de dialogue pour afficher les médias enregistrés
    Dialog {
        id: mediaDialog
        title: "Recorded Media"
        width: 600
        height: 600

        Column {
            spacing: 20

            // Image affichée dans le dialogue
            Image {
                id: dialogImage
                width: parent.width * 0.9
                height: 200
                fillMode: Image.PreserveAspectFit
                visible: false
            }

            // Vidéo affichée dans le dialogue
            VideoOutput {
                id: dialogVideo
                width: parent.width * 0.9
                height: 200
                visible: false
            }

            // Lecteur vidéo pour lire la vidéo enregistrée
            MediaPlayer {
                id: videoPlayer
                videoOutput: dialogVideo
            }

            // Liste des images capturées
            ListView {
                id: imageListView
                width: parent.width
                height: 150
                model: ListModel {}

                delegate: Item {
                    width: parent.width
                    height: 50

                    Row {
                        spacing: 10

                        Text {
                            text: fileName  // Affiche le nom du fichier image
                            color: "blue"
                            font.underline: true
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    console.log("Attempting to open:", fileName);  // Affiche le fichier sélectionné
                                    if (Qt.openUrlExternally(fileName) === false) {
                                        console.error("Failed to open the file:", fileName);  // Erreur si l'ouverture échoue
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Liste des vidéos enregistrées
            ListView {
                id: videoListView
                width: parent.width
                height: 150
                model: ListModel {}

                delegate: Item {
                    width: parent.width
                    height: 50

                    Row {
                        spacing: 10

                        Text {
                            text: fileName  // Affiche le nom du fichier vidéo
                            color: "blue"
                            font.underline: true
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    console.log("Attempting to open:", fileName);  // Affiche le fichier sélectionné
                                    if (Qt.openUrlExternally(fileName) === false) {
                                        console.error("Failed to open the file:", fileName);  // Erreur si l'ouverture échoue
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Bouton pour fermer le dialogue
            Button {
                text: "Close"
                onClicked: {
                    mediaDialog.close();  // Ferme le dialogue
                }
            }
        }
    }

    // Fonction pour charger la liste des images capturées
    function loadImageList() {
        var imageDir = "C:/Users/HP/Pictures/";  // Répertoire des images
        var imageFiles = ["captured_image.jpg", "captured_image1.jpg", "image3.jpg"];  // Liste des fichiers images

        imageListView.model.clear();  // Vide la vue actuelle
        for (var i = 0; i < imageFiles.length; i++) {
            imageListView.model.append({ "fileName": imageDir + imageFiles[i] });  // Ajoute chaque image à la liste
        }
    }

    // Fonction pour charger la liste des vidéos enregistrées
    function loadVideoList() {
        var videoDir = "C:/Users/HP/Videos/";  // Répertoire des vidéos
        var videoFiles = ["video_0041.mp4", "video_00042.mp4", "video_0024.mp4"];  // Liste des fichiers vidéos

        videoListView.model.clear();  // Vide la vue actuelle
        for (var i = 0; i < videoFiles.length; i++) {
            videoListView.model.append({ "fileName": videoDir + videoFiles[i] });  // Ajoute chaque vidéo à la liste
        }
    }

    // Charge les listes d'images et de vidéos lorsque l'application est prête
    Component.onCompleted: {
        loadImageList();
        loadVideoList();
    }
}
