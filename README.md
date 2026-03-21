# DSM-P3-G09-2025-1
Repositório do GRUPO 03 do Projeto Interdisciplinar do 5º semestre DSM 2026/1. Alunos: Cláudio de Melo Júnior, João Vitor Nicolau e Luís Pedro Dutra Carrocini.

---
<br>

# PI 5° Semestre - Sistema de Chamados (Um sistema para abertuura de chamados para prefeituras com classificador de IA)

Este projeto é o quinto PI (Projeto Interdisciplinar) do curso de DSM (Desenvolvimento de Software Multiplataforma) da Faculdade de Tecnologia Fatec Franca Dr. Thomaz Novelino. Seu objetivo é integrar os conhecimentos adquiridos nas principais disciplinas do terceiro semestre: Computação em Nuvem I, Programação de Dispositivos Móveis II e Aprendizado de Máquina. O resultado é um aplicativo desenvolvido em Flutter, cuja o objetivo é que pessoas comuns (cidadãos) façam a criação de chamados/suportes de necessidades na cidade a suas respectivas prefeituras. Após a criação o modelo de IA irá classificar o tipo de chamado e suas urgência. Aparecendo posteriormente os chamados em um painel administrativo (Web), atribuindo-os aos técnicos que poderão acompanhar e documentar as atividades no seu aplicativo móvel.

<br>

## 📄 Descrição

O aplicativo apresenta as seguintes telas e funcionalidades:

### Usuário não logado:
* **Login**: Permite o acesso do usuário à sua área, desde que informe seu CPF e senha corretamente.

### Usuário logado (Pessoas/Cidadão):
* **Home**: Exibe todos os chamados abertos pelo seu usuário com seus status. 
* **Criar Chamado**: Permite a criação de chamados, informando somente a descrição detalhada do problema e necessidade.
* **Dados do usuário**: Exibe os dados do usuário, cadastrados pelos gerenciadores da prefeitura, com opção de edição de alguns dados específicos.

### Usuário logado (Técnico):
* **Home**: Exibe todos os chamados em que o técnico esteja envolvido com usa equipe. 
* **Gerenciar Chamado**: Permite a inclusão de atividades e finalização do chamado.
* **Dados do usuário**: Exibe os dados do usuário, cadastrados pelos gerenciadores da prefeitura, com opção de edição de alguns dados específicos.

### Níveis de acesso do usuário:
* **Gestor da Unidade**: Nível mais alto. Pode gerenciar todos os outros níveis de usuários cadastrados no sistema, que sejam da mesma unidade que a sua. Também pode fazer o gerenciamento dos chamados abertos. Um Gestor da Unidade não pode criar outro de mesmo nível, essa criação de licença é feita pelos gerenciados da aplicação somente. Seu acesso é somente ao painel administrativo (Web), não podendo entrar com o mesmo cadastro no APP.
* **Gestor Comum**: Tem as mesmas permissões que o Gestor da Unidade, somente não pode gerenciar outros gestores de mesmo nível ou superior. Seu acesso é somente ao painel administrativo (Web), não podendo entrar com o mesmo cadastro no APP.
* **Técnico**: Pode incluir atividades nos chamados ao qual ele esteja envolvido pelas suas equipes, também podendo conclui-los. Seu acesso é somente ao aplicativo, em uma área exclusiva para técnicos, não podendo criar chamados com as mesmas credenciais.
* **Pessoa/Cidadão**: Pode fazer a criação de chamados, além de acompanhar o desenvolvimento deles. Seu acesso é somente ao aplicativo, em uma área exclusiva para os cidadãos.

### Fluxo dos chamados:
<img src="/prints/fluxo-chamados.png">

<br>

## 📁 Documentação do Projeto
### 📒 [Documento Final](https://github.com/FatecFranca/DSM-P3-G09-2025-1/raw/main/docs/Documentacao-PI-3-Semestre.pdf)
### 🎬 [Vídeo de Apresentação](https://youtu.be/F0ldIhUy5Fs)

<br>

## 📦 Aparência

### Web (Painel Administrativo)
#### Login
<img src="/prints/web/login.png">

#### Outros
<img src="/prints/web/login.png">

### Mobile
#### Login
<img src="/prints/mobile/login.png">

#### Outros
<img src="/prints/outros/login.png">

<br><br>

## 📃 Obter uma cópia

Para obter uma cópia, basta baixar todos os arquivos deste repositório e seguir os passos para a instalação logo abaixo.

<br>

## 📋 Pré-requisitos

Para o funcionamento pleno do site é necessário:

* Um navegador com suporte a JavaScript e acesso à internet.
* Ter o banco de dados PostGreSQL instalado localmente ou acessível na nuvem (ajustes no SGBD podem ser necessários conforme o ambiente).

<br>

## 🔧 Instalação

1. Baixe os arquivos e pastas deste repositório e coloque-os em uma pasta local.
2. Certifique-se de estar conectado à internet.
3. Ative o JavaScript em seu navegador.
4. Continuar....

<br>

## 🛠️ Construído com

**Ferramentas:**
* Visual Studio Code - Editor de código-fonte
* Draw.io - Diagramas
* Postman - Testes de API (Back-End)
* Figma - Protótipos da aplicação
* IA's (DeepSeek e Qwen) - Consultas para crição de códigos diversos, correção de bugs e melhoria em performance

**Linguagens e Tecnologias:**
* Flutter - Framework para o desenvolvimento do APP (dart)
* Next.js - Framework para o desenvolvimento Web (js)
* Node.js - Framework para o desenvolvimento da API (js)
* PostGreSQL - Banco de dados
* Prisma ORM - Interface com o banco de dados

<br>

## ✒️ Autores

* **[Cláudio de Melo Júnior](https://github.com/Claudio-Fatec)** — Atividades;
* **[João Vitor Nicolau](https://github.com/Joao-Vitor-Nicolau-dos-Santos)** — Atividades;
* **[Luís Pedro Dutra Carrocini](https://github.com/luis-pedro-dutra-carrocini)** — Atividades;

<br>

## 🎁 Agradecimentos

Agradecemos aos professores que nos acompanharam no curso, e durante esse semestre inteiro, transmitindo seus conhecimentos para nós. Somos gratos especialmente aos das disciplinas fundamentais para este projeto:

* **[Prof. Alessandro Fukuta](https://github.com/alessandro-fukuta)** — Computação em Nuvem I;
* **[Prof. Adriano Donisete Cassiano]()** — Programação de Dispositivos Móveis II;
* **[Prof. Jaqueline Brigladori Pugliesi]()** — Aprendizado de Máquina;

---

Este projeto foi desenvolvido no início de nossa jornada acadêmica. Temos orgulho deste projeto por ser um dos nossos primeiros — e o primeiro com aprendizagem de máquina! Releve nosso "código de iniciante" 😊.  
Esperamos que seja útil para você em algum projeto! ❤️

