[consul-servers-bootstrap]
${replace(masters,",", "\n")}

[nomad-servers-bootstrap:children]
consul-servers-bootstrap