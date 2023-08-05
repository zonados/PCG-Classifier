# PCG-classifier
Deep Learning-Based Classification of Phonocardiogram Signals Using CNN-BiLSTM Network and Empirical Mode Decomposition

**Citation of the code**: De Sousa, J. C., & Altuve, M. (2023). Deep Learning-Based Classification of Phonocardiogram Signals Using CNN-BiLSTM Network and Empirical Mode Decomposition [Source Code]. https://github.com/zonados/PCG-Classifier
## Abstract
Cardiovascular diseases (CVDs) remain the leading cause of mortality globally, underscoring the importance of early and accurate detection for timely intervention. Auscultation, often initiated in initial medical consultations, offers a noninvasive and cost-effective approach to diagnose various cardiac conditions, primarily through the analysis of phonocardiographic signals (PCGs). In this study, we propose an automatic classification model for PCG signals by leveraging the combined power of a Convolutional Neural Network (CNN) and a Bidirectional Long Short-Term Memory Network (BiLSTM). Our model takes as input the Mel-frequency cepstral coefficients (MFCCs) derived from reconstructed PCG signals using the Intrinsic Mode Functions (IMFs) obtained through the Improved Complete Ensemble Empirical Mode Decomposition with Adaptive Noise (ICEEMDAN) method. Multiple combinations of IMFs are examined for signal reconstruction, and the optimal combination achieves an average accuracy of 93.3%, specificity of 95.9%, and sensitivity of 79.6%. These findings highlight the potential of the proposed model in accurately classifying PCG signals, suggesting its utility in aiding the diagnosis and management of cardiac conditions. The study contributes to the advancement of automated techniques for PCG signal analysis, potentially improving the efficiency and reliability of cardiovascular disease diagnosis.

## Database
For the implementation of this work, the database provided for the PhysioNet Computing in Cardiology Challenge 2016 is used. This database consists of 6 different datasets obtained through measurements in various parts of the body and includes data from both healthy and pathological patients, including records of children and adults. PCG records can have a duration ranging from 5 to 120 seconds and come from clinical environments or home visits.
Entre los 6 conjuntos de datos se cuenta en total con 3240 registros (formato .WAV), provenientes de 764 pacientes con una frecuencia de muestreo de 2000 Hz y con una resolución de 16 bits. Adicionalmente, se cuenta con anotaciones de si los registros presentan o no alguna anomalía. Dichas anomalías están relacionadas con afecciones previas que ha sufrido el paciente y estas pueden ser defectos en las válvulas cardíacas o enfermedades de la arteria coronaria. Cabe destacar que esta base de datos se encuentra disponible para su descarga de manera gratuita (ver: https://physionet.org/content/challenge-2016/1.0.0/)

![figura2_ingles](https://github.com/zonados/PCG-Classifier/assets/60301489/639b8a9f-8ec4-4b73-929e-3460a475f9f2)

Example of a phonocardiographic signal and the different states of the cardiac cycle.

## The proposed classification model
The proposed model consists of signal preprocessing, segmentation into different states of the cardiac cycle, decomposition and reconstruction of the signal based on its intrinsic mode functions (IMFs), feature extraction using Mel cepstral coefficients, signal standardization, and finally, the classification model.

![Esquema](https://github.com/zonados/PCG-Classifier/assets/60301489/42489e90-262d-4209-adcb-c56bf288b1b9)
Block diagram of the proposed methodology.

![Picture4_ingles](https://github.com/zonados/PCG-Classifier/assets/60301489/661eb5c8-746d-4b78-a8d1-af44feb42092)
Classification model based on the combination of a CNN (Convolutional Neural Network) and a BiLSTM (Bidirectional Long Short-Term Memory).

## Obtained results
The results were obtained from different combinations of intrinsic mode functions. Specifically, the signal is reconstructed using the first L2 modes. These modes are obtained using the Improved CEEMDAN algorithm (see: http://bioingenieria.edu.ar/grupos/ldnlys/metorres/re_inter.htm).
![Picture5_ingles](https://github.com/zonados/PCG-Classifier/assets/60301489/4b75f935-9b20-4d1f-8e5a-20fc80047c15)

Sensitivity, Specificity, and Average Accuracy for different values of L2.
