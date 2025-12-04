class AppValidators{
  AppValidators._();


  static String? validateEmail(String? val){
    RegExp emailRegex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    if(val == null || val.trim().isEmpty){
      return 'This field is required';
    }
    else if(emailRegex.hasMatch(val) == false){
      return 'Enter valid email';
    }
    else{
      return null;
    }
  }

  static String? validatePassword(String? val){
    RegExp passRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])');
    if(val == null || val.trim().isEmpty){
      return 'This field is required';
    }
    else if(val.length < 8 || !passRegex.hasMatch(val)){
      return 'Enter strong password please';
    }
    else{
      return null;
    }
  }

  static String? validateConfirmPassword(String? val,String? password){
    if(val == null || val.isEmpty){
      return 'This field is required';
    }
    else if(val != password){
      return 'Passwords are not matching';
    }
    else{
      return null;
    }
  }

  static String? validateFullName(String? val){
    if(val == null || val.isEmpty){
      return 'This field is required';
    }
    else{
      return null;
    }
  }
  static String? validateAge(String? val){
    if(val == null || val.isEmpty){
      return 'This field is required';
    }else if(int.tryParse(val.trim()) == null){
      return 'Enter nums only ';
    }
    else{
      return null;
    }
  }



}