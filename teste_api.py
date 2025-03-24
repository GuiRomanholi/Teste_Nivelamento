from flask import Flask, request, jsonify
import pandas as pd

app = Flask(__name__)

# Carregar o arquivo CSV de operadoras
# Substitua pelo caminho correto do seu arquivo CSV
df_operadoras = pd.read_csv('operadoras_ativas.csv')

@app.route('/search', methods=['GET'])
def search_operadoras():
    query = request.args.get('q', default="", type=str)
    
    if query == "":
        return jsonify({"message": "Nenhuma consulta fornecida"}), 400
    
    # Realiza a busca nos campos relevantes, por exemplo, nome e CNPJ
    results = df_operadoras[df_operadoras['razao_social'].str.contains(query, case=False, na=False)]
    
    if results.empty:
        return jsonify({"message": "Nenhuma operadora encontrada para a consulta."}), 404
    
    # Retorna os 10 primeiros resultados
    results = results[['razao_social', 'cnpj', 'nome_fantasia', 'modalidade', 'endereco_eletronico']].head(10)
    return jsonify(results.to_dict(orient='records'))

if __name__ == '__main__':
    app.run(debug=True)