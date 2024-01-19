import os
import tensorflow as tf
import tensorflow_hub as hub
import tempfile
import subprocess

from iree.compiler import tf as tfc

# Print version information for future notebook users to reference.
print("TensorFlow version: ", tf.__version__)

ARTIFACTS_DIR = os.path.join(tempfile.gettempdir(), "iree", "colab_artifacts")
os.makedirs(ARTIFACTS_DIR, exist_ok=True)
print(f"Using artifacts directory '{ARTIFACTS_DIR}'")

HUB_PATH = "https://www.kaggle.com/models/google/mobilenet-v2/frameworks/TensorFlow2/variations/035-224-classification/versions/2"
model_path = hub.resolve(HUB_PATH)
print(f"Downloaded model from tfhub to path: '{model_path}'")

loaded_model = tf.saved_model.load(model_path)
serving_signatures = list(loaded_model.signatures.keys())
print(f"Loaded SavedModel from '{model_path}'")
print(f"Serving signatures: {serving_signatures}")

# Also check with the saved_model_cli:
print("\n---\n")
print("Checking for signature_defs using saved_model_cli:\n")

result = subprocess.run(['saved_model_cli', 'show', '--dir', model_path, '--tag_set', 'serve', '--signature_def', 'serving_default'],
        capture_output=True, text=True)
print(result.stdout)

call = loaded_model.__call__.get_concrete_function(tf.TensorSpec([1, 224, 224, 3], tf.float32))

# Save the model, setting the concrete function as a serving signature.
# https://www.tensorflow.org/guide/saved_model#saving_a_custom_model
resaved_model_path = '/tmp/resaved_model'
tf.saved_model.save(loaded_model, resaved_model_path, signatures=call)
print(f"Saved model with serving signatures to '{resaved_model_path}'")

# Load the model back into memory and check that it has serving signatures now
reloaded_model = tf.saved_model.load(resaved_model_path)
reloaded_serving_signatures = list(reloaded_model.signatures.keys())
print(f"\nReloaded SavedModel from '{resaved_model_path}'")
print(f"Serving signatures: {reloaded_serving_signatures}")

# Also check with the saved_model_cli:
print("\n---\n")
print("Checking for signature_defs using saved_model_cli:\n")

result = subprocess.run(['saved_model_cli', 'show', '--dir', resaved_model_path, '--tag_set', 'serve', '--signature_def', 'serving_default'],
        capture_output=True, text=True)
print(result.stdout)

output_file = os.path.join(ARTIFACTS_DIR, "mobilenet_v2.vmfb")
# As compilation runs, dump an intermediate .mlir file for future inspection.
iree_input = os.path.join(ARTIFACTS_DIR, "mobilenet_v2_iree_input.mlir")

tfc.compile_saved_model(
    resaved_model_path,
    output_file=output_file,
    save_temp_iree_input=iree_input,
    import_type="SIGNATURE_DEF",
    saved_model_tags=set(["serve"]),
    target_backends=["vmvx"])

print(f"Saved compiled output to '{output_file}'")
print(f"Saved iree_input to      '{iree_input}'")
