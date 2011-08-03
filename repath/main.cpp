#include <QByteArray>
#include <QFile>
#include <QDebug>

int main(int argc, char *argv[])
{
	if (argc != 5) {
		qDebug() << "usage: repath <input-file> <output-file> <from-string> <to-string>";
		return 0;
	}

	QByteArray data;
	
	QFile input(argv[1]);
	if (input.open(QFile::ReadOnly)) {
		data = input.readAll().replace(argv[3], argv[4]);
		input.close();
	} else {
		qDebug() << "failed to open input file: " << argv[1];
	}

	QFile output(argv[2]);
	if (!data.isEmpty() && output.open(QFile::WriteOnly)) {
		output.write(data);
	} else {
		qDebug() << "failed to open output file: " << argv[2];
	}

	return 0;
}