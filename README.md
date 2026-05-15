📊 Controle de Gastos

Aplicativo mobile desenvolvido em Flutter para gerenciamento financeiro pessoal, permitindo o controle de despesas, categorização de gastos, visualização de gráficos e acompanhamento financeiro de forma simples e intuitiva.

🚀 Tecnologias Utilizadas
Flutter
Dart
Hive / SQLite
Provider ou Riverpod
fl_chart
Intl
UUID

✨ Funcionalidades
🏠 Dashboard
Resumo financeiro do mês
Total gasto e saldo disponível
Últimas despesas cadastradas
Gráfico de gastos por categoria
Filtro rápido por período

➕ Cadastro de Despesas
Adicionar novas despesas
Seleção de categoria
Escolha de data com DatePicker
Validação de formulário
Feedback visual para erros

📋 Histórico
Listagem completa de despesas
Ordenação por data
Agrupamento mensal
Busca por título
Filtros por categoria e período
Editar e remover despesas

🏷️ Categorias
Categorias padrão e customizadas
Seleção de cor e ícone
Total gasto por categoria
CRUD completo de categorias

📈 Relatórios & Gráficos
Gráfico de pizza
Gráfico de barras
Gráfico de linha
Comparativo mensal

🎨 UX & Interface
Tema claro/escuro
Navegação intuitiva
Estados de carregamento
Empty states amigáveis
Animações de transição

📂 Estrutura do Projeto
lib/
│
├── core/
│   ├── theme/
│   ├── constants/
│   └── utils/
│
├── features/
│   ├── dashboard/
│   ├── expenses/
│   ├── categories/
│   └── reports/
│
├── models/
│   ├── despesa_model.dart
│   └── categoria_model.dart
│
├── providers/
│   ├── despesa_provider.dart
│   └── categoria_provider.dart
│
├── services/
│   └── database_service.dart
│
├── widgets/
│   ├── expense_card.dart
│   ├── category_chip.dart
│   └── charts/
│
├── routes/
│   └── app_routes.dart
│
└── main.dart

🛠️ Dependências

Adicione no arquivo pubspec.yaml:

dependencies:
  flutter:
    sdk: flutter

  provider: ^6.1.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  fl_chart: ^0.68.0
  intl: ^0.19.0
  uuid: ^4.5.1
▶️ Como Executar o Projeto
1️⃣ Clone o repositório
git clone https://github.com/seu-usuario/controle-gastos.git
2️⃣ Acesse a pasta
cd controle-gastos
3️⃣ Instale as dependências
flutter pub get
4️⃣ Execute o projeto
flutter run

🧠 Modelagem de Dados
Despesa
class Despesa {
  final String id;
  final String titulo;
  final double valor;
  final DateTime data;
  final String categoriaId;
}
Categoria
class Categoria {
  final String id;
  final String nome;
  final int cor;
  final IconData icone;
}

📱 Navegação

O aplicativo utiliza um BottomNavigationBar com 4 abas principais:

Aba	Descrição
🏠 Dashboard	Visão geral financeira
➕ Adicionar	Cadastro de despesas
📋 Histórico	Histórico completo
🏷️ Categorias	Gerenciamento de categorias

📊 Roadmap
 Estrutura inicial do projeto
 Modelagem de dados
 Gerenciamento de estado
 Dashboard completo
 CRUD de despesas
 CRUD de categorias
 Relatórios avançados
 Exportação PDF
 Backup na nuvem
 Notificações
 Testes automatizados

🔥 Melhorias Futuras
Integração com APIs bancárias
Controle de receitas
Metas financeiras
Login social
Sincronização em nuvem
Multiusuário

🤝 Contribuição

Contribuições são bem-vindas!

Faça um fork do projeto
Crie uma branch:
git checkout -b minha-feature
Commit suas alterações:
git commit -m "feat: minha nova feature"
Push da branch:
git push origin minha-feature
Abra um Pull Request 🚀

👨‍💻 Autor

Desenvolvido por Caio Sousa 🚀
