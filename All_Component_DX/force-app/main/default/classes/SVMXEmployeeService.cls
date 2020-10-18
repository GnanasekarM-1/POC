@RestResource(urlMapping='/svmx/sample/Employee/*')
global class SVMXEmployeeService {

  @HttpPost
  global static String doPost(String name) {
    return 'Hello ' + name + '!';
  }
}