# Create BERT model for natural language processing on task inputs

import pandas as pd
from sklearn.model_selection import train_test_split
from transformers import BertTokenizer
from sklearn.preprocessing import LabelEncoder
import torch
from transformers import BertForSequenceClassification, Trainer, TrainingArguments
import pickle
from transformers import TFBertForSequenceClassification
import json

class TaskDataset(torch.utils.data.Dataset):
    def __init__(self, encodings, labels):
        self.encodings = encodings
        self.labels = labels

    def __len__(self):
        return len(self.labels)

    def __getitem__(self, idx):
        return {
            'input_ids': torch.tensor(self.encodings['input_ids'][idx]),
            'attention_mask': torch.tensor(self.encodings['attention_mask'][idx]),
            'labels': torch.tensor(self.labels[idx]),
        }

# Load the dataset
data = pd.read_csv('task_input_data.csv', quotechar='"')

# Combine 'Task Name' and 'Task Description' as the input text
data['text'] = data['Task Name'] + ". " + data['Task Description']

# Extract inputs and labels
texts = data['text']
labels = data['Task Type']

# Split the data for training and validation
train_texts, val_texts, train_labels, val_labels = train_test_split(
    texts, labels, test_size=0.2, random_state=42
)

# Preprocess the text using BERT tokenizer
tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')

# Tokenize and encode inputs
train_encodings = tokenizer(list(train_texts), truncation=True, padding=True, max_length=128)
val_encodings = tokenizer(list(val_texts), truncation=True, padding=True, max_length=128)

# Encode task types (e.g., Work, Personal) to integers
label_encoder = LabelEncoder()
train_labels = label_encoder.fit_transform(train_labels)
val_labels = label_encoder.transform(val_labels)

# Create the PyTorch datasets for BERT
train_dataset = TaskDataset(train_encodings, train_labels)
val_dataset = TaskDataset(val_encodings, val_labels)

# Use the Hugging Face transformers library to fine-tune BERT
model = BertForSequenceClassification.from_pretrained('bert-base-uncased', num_labels=len(label_encoder.classes_))

training_args = TrainingArguments(
    output_dir='./results',          # Save model checkpoints
    evaluation_strategy="epoch",
    learning_rate=2e-5,
    per_device_train_batch_size=16,
    num_train_epochs=3,
    weight_decay=0.01,
    save_total_limit=1,
)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=train_dataset,
    eval_dataset=val_dataset,
)

# Train the model
trainer.train()

# Export the BERT model, tokenizer, and label mapping
model.save_pretrained('./task_classifier_model')
tokenizer.save_pretrained('./task_classifier_model')

with open('./task_classifier_model/label_encoder.pkl', 'wb') as f:
    pickle.dump(label_encoder, f)

# Convert label_encoder.pkl to .json to use in Flutter
with open('./task_classifier_model/label_encoder.pkl', 'rb') as f:
    label_encoder = pickle.load(f)

# Convert label encoder classes to a JSON dictionary
label_mapping = {i: label for i, label in enumerate(label_encoder.classes_)}

# Save as a JSON file
with open('./task_classifier_model/label_encoder.json', 'w') as f:
    json.dump(label_mapping, f)

print("Label encoder converted to label_encoder.json!")

# Convert the model to TensorFlow format for Flutter app integration
model = TFBertForSequenceClassification.from_pretrained('./task_classifier_model')

# Save as TensorFlow SavedModel
model.save('./saved_model')

# Convert to TensorFlow Lite and save the model
import tensorflow as tf
converter = tf.lite.TFLiteConverter.from_saved_model('./saved_model')
tflite_model = converter.convert()

with open('task_classifier.tflite', 'wb') as f:
    f.write(tflite_model)

print("Model training and conversion completed!")
