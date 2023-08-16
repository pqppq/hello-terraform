output "upper_names" {
	value = [for name in var.user_names : upper(name)]
}

output "bios" {
	# {for <KEY>, <VALUE> in <MAP> : <OUTPUT_KEY> => <OUTPUT EXPRESSION>}
	value = [for name, role in var.hero_thousand_faces : "${name} is the ${role}"]
}

output "for_directive_index" {
	value = "%{ for i, name in var.user_names }(${i}) ${name}%{ endfor }"
	# => "(0) neo, (1) trinity, (2) morpheus"
}
