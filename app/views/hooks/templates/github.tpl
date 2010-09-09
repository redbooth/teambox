{{#payload}}
### New code: {{#repository}}[{{name}}]({{url}}){{/repository}} ###
  
{{#commits}}
* Commit [{{id}}]({{url}}) from {{#author}} [{{name}}](mailto:{{email}}){{/author}}

<blockquote>
{{message}}
</blockquote>

{{/commits}}

before: {{before}}

After: {{after}}
{{/payload}}