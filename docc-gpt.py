import argparse
import openai
import os
import subprocess

arg_parser = argparse.ArgumentParser()
arg_parser.add_argument('package', help="The folder containing your Swift Package")
arg_parser.add_argument('-k', '--key', help="Your secret API key for OpenAI")
arg_parser.add_argument('-m', '--model', default="code-davinci-002", help="The OpenAI model to use")

args = arg_parser.parse_args()
openai.api_key = args.key

def generate_prompt(file):
    initial_prompt = open("prompt.txt", "r").read()
    file_contents = file.read()
    return f"""
    {initial_prompt}

    Code:
    ```swift
    {file_contents}
    ```

    Documented:
    ```swift
    
    """

def document_file(file):
    file = open(file, "r+")
    prompt = generate_prompt(file)
    max_tokens = 2048-len(prompt)
    completion = openai.Completion.create(
        max_tokens=max_tokens,
        model=args.model, 
        prompt=prompt,
        stop=["```"])

    response_text = completion.choices[0].text
    file.seek(0)
    file.write(response_text)
    file.close()

def document_files(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".swift"):
                absolute_path = os.path.join(root, file)
                abs_file = open(absolute_path, "r+")
                document_file(abs_file)

document_files(args.package)

subprocess.run(f"git diff", shell=True)
subprocess.run(f"git restore {package_path}", shell=True)