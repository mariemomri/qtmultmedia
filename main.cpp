#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QMediaRecorder>
#include <QMediaFormat>
#include <QCamera>
#include <QImageCapture>
#include <QQmlContext>  // Permet de partager des objets C++ avec QML

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    // Active le scaling haute résolution pour les versions antérieures à Qt 6
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    // Crée une instance de l'application Qt Quick (sans fenêtre principale)
    QGuiApplication app(argc, argv);

    // Crée un moteur pour charger et exécuter le fichier QML
    QQmlApplicationEngine engine;

    // Crée un objet QMediaFormat pour définir les paramètres du fichier vidéo (codec et format)
    QMediaFormat mediaFormat;
    mediaFormat.setVideoCodec(QMediaFormat::VideoCodec::H264);  // Définie le codec vidéo sur H264
    mediaFormat.setFileFormat(QMediaFormat::FileFormat::MPEG4); // Définit le format de fichier sur MPEG4

    // Crée un enregistreur multimédia et configure son format avec le format défini précédemment
    QMediaRecorder *mediaRecorder = new QMediaRecorder;
    mediaRecorder->setMediaFormat(mediaFormat);

    // Partage l'enregistreur multimédia avec le code QML afin qu'il soit accessible dans QML
    engine.rootContext()->setContextProperty("mediaRecorder", mediaRecorder);

    // Définit l'URL du fichier QML à charger
    const QUrl url(QStringLiteral("qrc:/main.qml"));

    // Vérifie si le fichier QML a bien été chargé
    // Si l'objet n'est pas créé, cela signifie que le fichier QML n'a pas été chargé correctement
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            // Si l'objet QML est nul et que l'URL correspond, quitte l'application avec une erreur
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    // Charge le fichier QML
    engine.load(url);

    // Exécute l'application Qt
    return app.exec();
}
