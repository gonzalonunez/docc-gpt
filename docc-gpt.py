import argparse
import os
import requests

arg_parser = argparse.ArgumentParser()
arg_parser.add_argument('dir', help="The folder whose contents you want to document")
arg_parser.add_argument('-k', '--key', help="Your secret API key for OpenAI")

args = arg_parser.parse_args()

ignored_files = [
    "Package.swift",
]

def document_file(file_path):
    file = open(file_path, "r+")
    instruction_file = open("instruction.txt", "r")
    response = requests.post(
        'https://api.openai.com/v1/edits', 
        headers={
            "Authorization": f"Bearer {args.key}",
            "Content-Type": "application/json",
        },
        json={
          "model": "code-davinci-edit-001",
          "input": file.read(),
          "instruction": instruction_file.read(),
          "temperature": 0,
          "top_p": 1
        })
        
    response_text = response.json()['choices'][0]['text']
    file.seek(0)
    file.write(response_text)
    file.close()

def document_files(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".swift") and file not in ignored_files:
                absolute_path = os.path.join(root, file)
                document_file(absolute_path)

document_files(args.dir)
