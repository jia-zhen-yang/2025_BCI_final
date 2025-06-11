## Data Description

**Overview**

This EEG dataset was collected to study the neural differences between children diagnosed with Attention-Deficit/Hyperactivity Disorder (ADHD) and neurotypical children. The dataset is suitable for EEG-based ADHD detection.

**Experimental Design / Paradigm**

- **Study Type**: Between-subjects design
- **Participants**: 121 children
  - 61 with ADHD
  - 60 neurotypical controls
- **Age Range**: 7–12 years
- **Diagnosis Criteria**: ADHD diagnosis confirmed by a psychiatrist based on **DSM-IV**
- **Task Condition**: **Resting-state EEG** with **eyes closed**
- **Medication Info**: ADHD participants had been treated with **Ritalin for up to 6 months**

**Procedure for Collecting Data**

- Each child was shown a sequence of images containing cartoon characters, and asked to count the number of characters in each image.
- The number of characters in each image was randomly chosen between 5 and 16, introducing variation in attentional load.
- Images were large and clearly visible, ensuring they were easy for children (ages 7–12) to recognize and count.
- Upon each response, the next image was presented immediately without delay, maintaining continuous visual stimulation throughout the recording.
- As a result, the total EEG recording time varied per subject, depending on individual response speed.
- Labels (ADHD or Control) were recorded in the class column.

**Hardware and Software Used**

- **EEG Amplifier**: Mitsar-201 EEG System
- **EEG Cap**: 19-channel setup following the **international 10–20 system**
- **Electrode Reference**: Linked earlobes (A1 and A2)
- **Sampling Rate**: 128 Hz
- **File Format**: .csv
- **Recording Environment**: Quiet room, minimal distraction

**Data Size**

- **Subjects**: 121 children
- **EEG Channels**: 19
  - Fz, Cz, Pz, C3, T3, C4, T4, Fp1, Fp2, F3, F4, F7, F8, P3, P4, T5, T6, O1, O2
  - **Reference Electrodes**: A1 and A2 (linked earlobes)
- **Total columns**: Fz, Cz, Pz, C3, T3, C4, T4, Fp1, Fp2, F3, F4, F7, F8, P3, P4, T5, T6, O1, O2, Class, ID  
    (Class: ADHD/Control, ID: Patient ID)

**Data Source and Ownership**

- **Dataset Title**: [EEG Dataset for ADHD](https://www.kaggle.com/datasets/danizo/eeg-dataset-for-adhd)
- **Onwer**: Shahed Univeristy
- **Use License**: Publicly available for research and academic purposes
- **Ethics**: Diagnoses performed by medical professionals; participants anonymized

## Model Framework
<img src="https://github.com/jia-zhen-yang/2025_BCI_final/blob/0d50f0a9e3e2f9c020f52a7aed6d6a78c089a485/assets/README_model%20framework.png" width="700"/><br>

## Data Processing
**Raw Independent Component Analysis**

<img src="https://github.com/jia-zhen-yang/2025_BCI_final/blob/0d50f0a9e3e2f9c020f52a7aed6d6a78c089a485/assets/README_Raw%20Independent%20Component%20Analysis_2.png"/><br>

<img src="https://github.com/jia-zhen-yang/2025_BCI_final/blob/0d50f0a9e3e2f9c020f52a7aed6d6a78c089a485/assets/README_Raw%20Independent%20Component%20Analysis.png"/><br>

**Filtered Independent Component Analysis**

<img src="https://github.com/jia-zhen-yang/2025_BCI_final/blob/0d50f0a9e3e2f9c020f52a7aed6d6a78c089a485/assets/README_Filtered%20Independent%20Component%20Analysis.png_2.png"/><br>

<img src="https://github.com/jia-zhen-yang/2025_BCI_final/blob/872c4e8fe3c844cf7a90ef8e00506155bb2a4d73/assets/README_Filtered%20Independent%20Component%20Analysis.png"/><br>

**Filtered ASR Independent Component Analysis**

<img src="https://github.com/jia-zhen-yang/2025_BCI_final/blob/0d50f0a9e3e2f9c020f52a7aed6d6a78c089a485/assets/README_Filtered%20ASR%20Independent%20Component%20Analysis_2.png"/><br>

<img src="https://github.com/jia-zhen-yang/2025_BCI_final/blob/0d50f0a9e3e2f9c020f52a7aed6d6a78c089a485/assets/README_Filtered%20ASR%20Independent%20Component%20Analysis.png"/><br>

**Analyzing the Hidden Independent Components within EEG Using ICA with ICLabel**

| EEG(19 chanels, 121 datasets) | Bandpass Filter | ASR | Brain | Muscle | Eye | Heart | Line | Channel Noise | Other | Total |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Raw |     |     | 6.0661 | 0.0579 | 1.4793 | 0.0083 | 8.7025 | 0.0744 | 2.6116 | 19.0000 |
| Filtered | ✓   |     | 12.8430 | 0.0826 | 2.0661 | 0.0000 | 0.0000 | 0.0909 | 3.9174 | 19.0000 |
| ASR | ✓   | ✓   | 13.9174 | 0.0909 | 1.6281 | 0.0000 | 0.0000 | 0.0579 | 3.3058 | 19.0000 |

## Classification Model
### Feature Extraction

<img src="https://github.com/jia-zhen-yang/2025_BCI_final/blob/0d50f0a9e3e2f9c020f52a7aed6d6a78c089a485/assets/README_PSD.jpg"/><br>

For each participant, the feature extraction process resulted in a feature vector of 4 (frequency bands) \*7 (channels)\*2(PSD+SE) features.

### Result

**SVM**

<img src="https://github.com/jia-zhen-yang/2025_BCI_final/blob/0d50f0a9e3e2f9c020f52a7aed6d6a78c089a485/assets/README_result_accuracy.jpg"/><br>

<img src="https://github.com/jia-zhen-yang/2025_BCI_final/blob/0d50f0a9e3e2f9c020f52a7aed6d6a78c089a485/assets/confusion%20matrix_SVM.jpg"/><br>

Average Training Accuracy 90.43%

Average Testing Accuracy 60.29%

recall ADHD : 63.93%

**XG-Boost**

<img src="https://github.com/jia-zhen-yang/2025_BCI_final/blob/0d50f0a9e3e2f9c020f52a7aed6d6a78c089a485/assets/confusion%20matrix_XGBoost.jpg"/><br>

Average Accuracy:100.00%

Specificity Control: 58.77%

Recall ADHD: 59.01%

## Quality Evaluation

**Literature Foundation and Protocol Validity**

The experimental paradigm—presenting visual stimuli (cartoon images) and requiring children to count the characters—is grounded in established literature that links visual attention deficits with ADHD. Similar visual attention tasks have been used in cognitive neuroscience studies to elicit differential EEG responses between neurotypical and ADHD participants.

**Data Collection Reliability**

The data was recorded in a quiet and distraction-free environment using a 19-channel EEG cap following the standard international 10–20 system, ensuring consistent electrode placement and quality signal acquisition. All recordings were performed under controlled conditions, minimizing environmental noise and ensuring reproducibility.

**Signal Preprocessing Rigor**

**Preprocessing included:**

- Band-pass filtering to retain relevant neural frequencies while excluding artifacts from low-frequency drift and high-frequency noise.
- Artifact Subspace Reconstruction (ASR) to automatically remove transient noise sources (e.g., eye blinks, muscle movements), ensuring cleaner and more interpretable EEG data.
- Channel selection focusing on 7 frontal and central channels most relevant to attentional processes.

**Feature Robustness**

Two complementary frequency-domain features—Power Spectral Density (PSD) and Spectral Entropy (SE)—were extracted from cleaned data. These features are commonly cited in EEG classification literature and are well-suited to capture the power distribution and signal complexity associated with attentional states.

**Classification Pipeline and Generalizability**

Two machine learning classifiers (SVM and XG-Boost) were trained and evaluated. While the testing accuracy shows moderate generalizability, the divergence between training and testing accuracy highlights potential overfitting and suggests the need for further cross-validation or ensemble methods. Nonetheless, the classification recall for ADHD remains promising, reinforcing the discriminative power of the extracted features.

## Validation

To evaluate the trained classifier, we use cross-validation on the dataset to assess its performance in accurately classifying motor imagery tasks. We also analyze classification metrics such as accuracy, recall to quantify the classifier's effectiveness.

## Usage

Describe the usage of their BCI model’s code. Explain the required environment and dependencies needed to run the code. Describe any configurable options or parameters within the code. Provide instructions on how to execute the code.

## File Description  
The data folder contains:

- raw_adhdata.csv: Raw EEG data
- subjects_selected/ folder: Includes EEG recordings from 121 subjects
- EEG_spectral_features.csv: Extracted EEG features used for model training

The model folder contains:

- SVM: Support Vector Machine classification model
- XGBoost: Extreme Gradient Boosting classification model

There are 5 steps before the implementation of models:

- cutdata_cleaned:  
    Splits the raw EEG dataset into 121 subject-specific files, including 61 ADHD and 60 control participants.
- Bandfilter:  
    Applies a band-pass filter to remove frequency components that are too high or too low.
- ASR  
    Performs Artifact Subspace Reconstruction to automatically remove transient EEG artifacts such as eye blinks or muscle noise.
- select7channels  
    Retains only the 7 frontal EEG channels of interest and removes all other channel data.
- feature_extraction  
    Extracts frequency-domain features such as Power Spectral Density (PSD) and Spectral Entropy (SE) from the cleaned EEG data.
