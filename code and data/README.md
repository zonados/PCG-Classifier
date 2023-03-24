# Code
En esta carpeta se encuentra el código empleado en el proyecto del clasificador de señales de PCG y las señales utilizadas. La carpeta "Training" contiene  las funciones originales aportadas por Physionet para la segmentación de las señales en las diferentes etapas de los sonidos cardiacos, entre otras funciones de interés.
Los datos utilizados pueden descargarse de manera gratuita de: https://physionet.org/content/challenge-2016/1.0.0/
Este sitio web permite obtener 6 carpetas con los conjuntos de datos para el entrenamiento, denominadas training-a, training-b, training-c, training-d, training-e y training-f.
La función, también ubicada dentro de la carpeta "training", que se encarga de leer todos los datos en las diferentes carpetas se llama main_Guardarsenales.m (deben descargarse los archivos con los datos previo a la utilización de esta rutina). Este script genera como resultado una estructura de Matlab que contiene las señales de entrenamiento para el modelo de Deep Learning.
El archivo main.m se encarga de realizar el preprocesamiento de las señales, el entrenamiento y las pruebas del modelo.
