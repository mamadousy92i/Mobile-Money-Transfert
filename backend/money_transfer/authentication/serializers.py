from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from rest_framework.validators import UniqueValidator

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    """Sérialiseur pour le modèle User."""
    
    class Meta:
        model = User
        fields = ['id', 'phone_number', 'email', 'first_name', 'last_name', 'kyc_status', 'date_joined']
        read_only_fields = ['id', 'date_joined', 'kyc_status']


class UserRegistrationSerializer(serializers.ModelSerializer):
    """Sérialiseur pour l'inscription des utilisateurs."""
    
    email = serializers.EmailField(
        required=True,
        validators=[UniqueValidator(queryset=User.objects.all())]
    )
    phone_number = serializers.CharField(
        required=True,
        validators=[UniqueValidator(queryset=User.objects.all())]
    )
    password = serializers.CharField(
        write_only=True,
        required=True,
        validators=[validate_password]
    )
    password_confirm = serializers.CharField(write_only=True, required=True)
    
    class Meta:
        model = User
        fields = ['phone_number', 'email', 'password', 'password_confirm', 'first_name', 'last_name']
    
    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({"password": "Les champs de mot de passe ne correspondent pas."})
        return attrs
    
    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = User.objects.create_user(**validated_data)
        return user


class UserProfileUpdateSerializer(serializers.ModelSerializer):
    """Sérialiseur pour la mise à jour du profil utilisateur."""
    
    class Meta:
        model = User
        fields = ['first_name', 'last_name', 'email']
        

class ChangePasswordSerializer(serializers.Serializer):
    """Sérialiseur pour le changement de mot de passe."""
    
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True, validators=[validate_password])
    confirm_password = serializers.CharField(required=True)
    
    def validate(self, attrs):
        if attrs['new_password'] != attrs['confirm_password']:
            raise serializers.ValidationError({"new_password": "Les champs de mot de passe ne correspondent pas."})
        return attrs
