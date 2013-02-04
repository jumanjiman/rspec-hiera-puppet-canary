class canary::parameterized(
  $foo_message = hiera('foo_message', 'broken')
){
  notify {'parameterized foo': message => $foo_message}
}
