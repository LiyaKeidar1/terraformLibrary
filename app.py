from flask import Flask, request, render_template
import psycopg2

app = Flask(__name__)

# Database connection configuration
db_config = {
    'dbname': 'library',
    'user': 'liya',
    'password': 'liya',
    'host': '10.0.2.5',  #private IP PostgreSQL VM
    'port': '5432',  
}

def connect_to_database():
    try:
        connection = psycopg2.connect(**db_config)
        return connection
    except Exception as e:
        print("Error connecting to the database:", str(e))
        return None

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/books', methods=['GET'])
def get_books():
    connection = connect_to_database()
    if connection:
        cursor = connection.cursor()
        cursor.execute("SELECT * FROM books;")
        books = cursor.fetchall()
        connection.close()
        return render_template('books.html', books=books)
    else:
        return "Database connection error"

@app.route('/add_book', methods=['POST'])
def add_book():
    title = request.form.get('title')
    author = request.form.get('author')

    connection = connect_to_database()
    if connection:
        cursor = connection.cursor()
        cursor.execute("INSERT INTO books (title, author) VALUES (%s, %s);", (title, author))
        connection.commit()
        connection.close()
        return "Book added successfully"
    else:
        return "Database connection error"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
