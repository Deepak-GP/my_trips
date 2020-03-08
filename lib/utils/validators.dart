
String requiredValidator(String value, String field)
{
  if(value.isEmpty)
  {
    return 'Please enter $field';
  }
  return null;
}


Function(String) composeValidators(String field, List<Function> validators) 
{
  return (value) 
  {
    if(validators != null && validators is List && validators.length > 0) 
    {
      for (var validator in validators) {
        final errMessage = validator(value, field) as String;
        if (errMessage != null) {
          return errMessage;
        }
      }
    }
    return null;
  };
}