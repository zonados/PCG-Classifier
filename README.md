# Clasificador-PCG
Clasificación de Registros Fonocardiográficos Usando Descomposición Empírica en Modos y Aprendizaje Profundo

## Abstract
Las enfermedades cardiovasculares representan la primera causa de muerte a nivel mundial. Es importante contar con técnicas de diagnóstico temprano que permitan detectar dichas enfermedades de manera de tratarlas adecuada y oportunamente. Uno de los primeros estudios que se le hace a un paciente ante una consulta médica es una auscultación, la cual puede ser representada mediante la señal fonocardiográfica o PCG, siendo este un método no invasivo y económico que permite diagnosticar con buena precisión diferentes enfermedades cardiacas. En este trabajo se desarrolla un modelo para la clasificación automática de registros PCG mediante la combinación de una red neuronal convolucional o CNN y una red bidireccional de gran memoria de corto plazo o BiLSTM. Este modelo toma como datos de entrada los coeficientes cepstrales de Mel o MFFC de la señal reconstruida, a partir de sus funciones de modo intrínseco IMF, los cuales se obtienen mediante el metodo ICEEMDAN. Se prueban diferentes combinaciones de IMF para la reconstruccion de las señales, donde la mejor combinación obtuvo en promedio una exactitud del 93.3%, una especificidad del 95.9% y una sensibilidad de 79.6%.

## Base de datos
Para la realizacion de este trabajo se emplea la base de datos dispuesta para el PhysioNet Computing in Cardiology Challenge 2016. Esta base de datos, consta de 6 conjuntos de datos diferentes, obtenidos mediante mediciones en diversas partes del cuerpo y que provienen tanto de pacientes sanos como patológicos, incluyendo en los registros datos de niñnos y de adultos. Los registros de PCG pueden contener una duracion entre 5 hasta 120 segundos y provienen de entornos clínicos o de visitas domiciliarias.
Entre los 6 conjuntos de datos se cuenta en total con 3240 registros (formato .WAV), provenientes de 764 pacientes con una frecuencia de muestreo de 2000 Hz y con una resolución de 16 bits. Adicionalmente, se cuenta con anotaciones de si los registros presentan o no alguna anomalía. Dichas anomalías están relacionadas con afecciones previas que ha sufrido el paciente y estas pueden ser defectos en las válvulas cardíacas o enfermedades de la arteria coronaria. Cabe destacar que esta base de datos se encuentra disponible para su descarga de manera gratuita (ver: https://physionet.org/content/challenge-2016/1.0.0/)
![Picture2](https://user-images.githubusercontent.com/60301489/227607758-819d3198-78da-4082-bf8e-c741d52313b8.png)
Ejemplo de una señal fonocardiográfica y los diferentes estados del ciclo cardiaco.

## Modelo de clasificación propuesto
El modelo propuesto consta de un pre-procesamiento de la señal, una segmentación en los diferentes estados del ciclo cardiaco, una descomposición y reconstrucción de la señal en función de sus funciones de modo intrínseco (IMF), una extracción de carcterísticas mediante los coeficientes cepstrales de Mel y una estandarización de la señal y finalmente el modelo de clasificación.

![Picture1](https://user-images.githubusercontent.com/60301489/227609396-42ee9fd8-6227-4477-88b4-90e52359c914.png)
diagrama de bloques de la metodología planteada.

![Picture4](https://user-images.githubusercontent.com/60301489/227609466-9ad1a7b1-90c6-4a3c-8d87-a0d91c3c8baf.png)
Modelo de clasificación basado en la combinación de una red CNN y una red BiLSTM.

## Resultados obtenidos
Los resultados fueron obtenidos a partir de diferentes combinaciones de las funciones de modo intrínseco. En particular, se reconstruye la señal con los primeros L2 modos. Dichos modos son obtenidos mediante el algoritmo Improved CEEMDAN (ver : http://bioingenieria.edu.ar/grupos/ldnlys/metorres/re_inter.htm)
![Picture5](https://user-images.githubusercontent.com/60301489/227610535-c7c6e77c-2417-4c76-9bfd-542691e361a9.png)
Sensibilidad, Especificidad y Exactitud promedio para diferentes valores de L2.
