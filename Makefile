DIR = files
MALICIOUS_DIR = malicious
INTERVAL = 5

antivirus: setup
	bash antivirusd.sh $(DIR) $(MALICIOUS_DIR) $(INTERVAL)

restore: setup
	bash restore.sh $(DIR) $(MALICIOUS_DIR)

# pre-build step
setup:
	mkdir -p $(MALICIOUS_DIR)
