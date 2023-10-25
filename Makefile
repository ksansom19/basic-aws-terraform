
clean-terraform: clean-Lab2 clean-Lab1

clean-Lab2:
	rm -rf Lab2/.terraform Lab2/terraform.tfstate.backup \
	Lab2/terraform.tfstate Lab2/sample.zip \
	Lab2/.terraform.lock.hcl

clean-Lab1:
	rm -rf Lab1/.terraform Lab1/terraform.tfstate.backup \
	Lab1/terraform.tfstate Lab1/.terraform.lock.hcl