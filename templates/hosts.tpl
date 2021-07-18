[vms]
%{ for ip in vms_adresss ~}
${ip}
%{ endfor ~}