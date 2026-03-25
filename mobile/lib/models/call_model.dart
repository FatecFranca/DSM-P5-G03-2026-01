class CallModel {
  final int? id;
  final int pessoaId;
  final int unidadeId;
  final String descricaoInicial;
  final String status; 
  final String urgencia; 
  final String prioridade; 
  final DateTime? dataInicio;
  final DateTime? dataFim;

  CallModel({
    this.id,
    required this.pessoaId,
    required this.unidadeId,
    required this.descricaoInicial,
    this.status = 'PENDENTE',
    this.urgencia = 'MEDIA',
    this.prioridade = 'MIN',
    this.dataInicio,
    this.dataFim,
  });

  Map<String, dynamic> toJson() {
    return {
      'PessoaId': pessoaId,
      'UnidadeId': unidadeId,
      'ChamadoDescricaoInicial': descricaoInicial,
      'Urgencia': urgencia,
      'Prioridade': prioridade,
    };
  }

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: json['ChamadoId'],
      pessoaId: json['PessoaId'] ?? 0,
      unidadeId: json['UnidadeId'] ?? 0,
      descricaoInicial: json['ChamadoDescricaoInicial'] ?? '',
      status: json['ChamadoStatus'] ?? 'PENDENTE',
      urgencia: json['ChamadoUrgencia'] ?? 'MEDIA',
      prioridade: json['ChamadoPrioridade'] ?? 'MIN',
      dataInicio: json['ChamadoDtAbertura'] != null
          ? DateTime.parse(json['ChamadoDtAbertura'])
          : null,
      dataFim: json['ChamadoDtEncerramento'] != null
          ? DateTime.parse(json['ChamadoDtEncerramento'])
          : null,
    );
  }
}
