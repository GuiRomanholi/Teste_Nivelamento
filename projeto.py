import os
import requests
import zipfile
from PyPDF2 import PdfReader
import pandas as pd

# URL direta do Anexo I
pdf_url = "https://www.gov.br/ans/pt-br/acesso-a-informacao/participacao-da-sociedade/atualizacao-do-rol-de-procedimentos/Anexo_I_Rol_2021RN_465.2021_RN627L.2024.pdf"

# Criar diretório para os arquivos baixados
os.makedirs("downloads", exist_ok=True)

# Nome do arquivo PDF
pdf_path = "downloads/Anexo_I.pdf"

# Baixar o PDF
response = requests.get(pdf_url)
with open(pdf_path, "wb") as file:
    file.write(response.content)

print("Download do PDF concluído!")

# Compactação do PDF em um arquivo ZIP
zip_path = "downloads/anexos.zip"
with zipfile.ZipFile(zip_path, 'w') as zipf:
    zipf.write(pdf_path, os.path.basename(pdf_path))

print("Compactação do PDF concluída!")

# Extração dos dados do PDF
pdf_reader = PdfReader(pdf_path)
data = []

for page in pdf_reader.pages:
    text = page.extract_text()
    if text:
        rows = text.split("\n")
        data.extend([row.split() for row in rows if row])

# Criando DataFrame e salvando como CSV
df = pd.DataFrame(data)
csv_path = "downloads/tabela.csv"
df.to_csv(csv_path, index=False, encoding='utf-8')

# Compactação do CSV
with zipfile.ZipFile("downloads/Dados_Tabela.zip", 'w') as zipf:
    zipf.write(csv_path, "tabela.csv")

print("Processo concluído com sucesso!")
