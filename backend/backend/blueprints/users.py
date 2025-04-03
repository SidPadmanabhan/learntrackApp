from flask import Blueprint, request, jsonify
from database import get_connection
from datetime import datetime

users_bp = Blueprint('users', __name__, url_prefix='/users')

@users_bp.route('/<user_id>', methods=['GET'])
def get_user(user_id):
    # In a real app, check authentication and authorization here
    auth_header = request.headers.get('Authorization')
    if not auth_header or not auth_header.startswith('Bearer '):
        return jsonify({'message': 'Unauthorized access'}), 401
    
    connection = get_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT id, name, email, age, created_at FROM users WHERE id = %s", (user_id,))
            user = cursor.fetchone()
            
            if user:
                # Convert to a format that can be serialized to JSON
                created_at = user['created_at']
                # Handle different types for created_at field
                if created_at:
                    if isinstance(created_at, str):
                        # Already a string, no need to format
                        created_at_str = created_at
                    elif hasattr(created_at, 'isoformat'):
                        # It's a datetime object
                        created_at_str = created_at.isoformat()
                    else:
                        # Fallback
                        created_at_str = str(created_at)
                else:
                    created_at_str = None
                    
                user_data = {
                    'uid': str(user['id']),
                    'name': user['name'],
                    'email': user['email'],
                    'age': user['age'],
                    'created_at': created_at_str
                }
                return jsonify(user_data), 200
            else:
                return jsonify({'message': 'User not found'}), 404
    finally:
        connection.close()
        
    return jsonify({'message': 'An error occurred'}), 500 