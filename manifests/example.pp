class canary::example {
  notify {'foo': message => hiera('foo_message', 'broken')}
}
