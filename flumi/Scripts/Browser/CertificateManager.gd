extends RefCounted
class_name CertificateManager

static var trusted_ca_certificates: Array[String] = []
static var ca_cache: Dictionary = {}

static func initialize():
	load_builtin_ca()
	print("Certificate Manager initialized with ", trusted_ca_certificates.size(), " trusted CAs")

static func load_builtin_ca():
	var ca_file = FileAccess.open("res://Assets/gurted-ca.crt", FileAccess.READ)
	var arson_ca_file = FileAccess.open("res://Assets/arson-ca.crt", FileAccess.READ)
	var clanker_ca_file = FileAccess.open("res://Assets/clanker-ca.crt", FileAccess.READ)
	if ca_file:
		var ca_cert_pem = ca_file.get_as_text()
		ca_file.close()
		
		var arson_ca_cert_pem = arson_ca_file.get_as_text()
		arson_ca_file.close()
		
		var clanker_ca_cert_pem = clanker_ca_file.get_as_text()
		clanker_ca_file.close()
		
		if not ca_cert_pem.is_empty():
			trusted_ca_certificates.append(ca_cert_pem)
			trusted_ca_certificates.append(arson_ca_cert_pem)
			trusted_ca_certificates.append(clanker_ca_cert_pem)
			print("Loaded built-in GURT CA certificates")
		else:
			print("Built-in CA certificate not yet configured")
	else:
		print("Could not load built-in CA certificate")
