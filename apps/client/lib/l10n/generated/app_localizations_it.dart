// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Anonymprove';

  @override
  String get language => 'Lingua';

  @override
  String get languageAutomatic => 'Automatica';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePersian => 'Persiano';

  @override
  String get sessionHeadline =>
      'Feedback costruttivo, senza rivelare chi ha detto cosa.';

  @override
  String get sessionDescription =>
      'Questa versione beta crea una sessione privata temporanea su questo dispositivo. Il recupero dell\'account e l\'accesso persistente arriveranno in seguito.';

  @override
  String get startPrivateSession => 'Avvia sessione privata';

  @override
  String get myGroups => 'I miei gruppi';

  @override
  String get temporarySessionIdentity => 'Identità temporanea della sessione';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get noAssessmentsYet => 'Nessun gruppo ancora';

  @override
  String get noAssessmentsMessage =>
      'Crea un gruppo o unisciti a uno esistente per iniziare.';

  @override
  String get join => 'Unisciti';

  @override
  String get create => 'Crea';

  @override
  String get createGroup => 'Crea gruppo';

  @override
  String get groupName => 'Nome del gruppo';

  @override
  String get joinGroup => 'Unisciti al gruppo';

  @override
  String get joinCode => 'Codice di accesso';

  @override
  String get saveJoinCode => 'Salva questo codice di accesso';

  @override
  String get joinCodeShareHint =>
      'Condividilo solo con le persone che vuoi nel gruppo. L\'API non mostrerà nuovamente il codice in seguito.';

  @override
  String get copyCode => 'Copia codice';

  @override
  String get joinCodeCopied => 'Codice copiato';

  @override
  String get iSavedIt => 'L\'ho salvato';

  @override
  String get cancel => 'Annulla';

  @override
  String get groupHealthHistory => 'Cronologia salute del gruppo';

  @override
  String get questionnaires => 'Questionari';

  @override
  String get noFeedbackRounds => 'Nessun ciclo di feedback';

  @override
  String get noFeedbackRoundsMessage =>
      'Richiedi un feedback su di te per iniziare.';

  @override
  String get groupHealthAssessment => 'Valutazione della salute del gruppo';

  @override
  String get yourFeedbackRound => 'Il tuo ciclo di feedback';

  @override
  String get groupMemberFeedback => 'Feedback su un membro del gruppo';

  @override
  String get assessGroupHealth => 'Valuta la salute del gruppo';

  @override
  String get requestFeedback => 'Richiedi feedback';

  @override
  String get statusDraft => 'Bozza';

  @override
  String get statusOpen => 'Aperto';

  @override
  String get statusClosed => 'Chiuso';

  @override
  String get statusExpired => 'Scaduto';

  @override
  String get statusClosedNoResults => 'Chiuso senza risultati';

  @override
  String roundListSubtitle(String status, int minResponses) {
    return '$status · minimo $minResponses risposte';
  }

  @override
  String get groupHealth => 'Salute del gruppo';

  @override
  String get feedbackRound => 'Ciclo di feedback';

  @override
  String get questions => 'Domande';

  @override
  String get oneHour => '1 ora';

  @override
  String get sixHours => '6 ore';

  @override
  String get twentyFourHoursRecommended => '24 ore · consigliato';

  @override
  String get threeDays => '3 giorni';

  @override
  String get sevenDays => '7 giorni';

  @override
  String get responseWindowQuestion =>
      'Quanto tempo devono avere le persone per rispondere?';

  @override
  String get extendResponsePeriodBy => 'Estendi il periodo di risposta di';

  @override
  String get endWithoutResultsTitle => 'Terminare senza risultati?';

  @override
  String get endWithoutResultsExplanation =>
      'La soglia di privacy non è stata raggiunta. Questa operazione termina definitivamente il ciclo senza mostrare risultati parziali.';

  @override
  String get endWithoutResults => 'Termina senza risultati';

  @override
  String get closeGroupHealthTitle => 'Chiudere la valutazione del gruppo?';

  @override
  String get closeFeedbackRoundTitle => 'Chiudere il ciclo di feedback?';

  @override
  String get closeGroupHealthExplanation =>
      'La soglia di privacy è stata raggiunta. Dopo la chiusura non sarà più possibile inviare risposte sulla salute del gruppo.';

  @override
  String get closeFeedbackRoundExplanation =>
      'La soglia di privacy è stata raggiunta. Dopo la chiusura non sarà più possibile inviare feedback.';

  @override
  String get closeAssessment => 'Chiudi valutazione';

  @override
  String get closeRound => 'Chiudi ciclo';

  @override
  String get feedbackSubmittedAnonymously =>
      'Feedback inviato in forma anonima.';

  @override
  String get assessmentNotOpened =>
      'Questa valutazione non è ancora stata aperta.';

  @override
  String get openGroupHealthAssessment => 'Apri valutazione del gruppo';

  @override
  String get openRound => 'Apri ciclo';

  @override
  String openingGroupHealthRequirement(int minResponses) {
    return 'Per aprire servono almeno $minResponses membri del gruppo idonei in totale.';
  }

  @override
  String openingFeedbackRequirement(int minResponses) {
    return 'Per aprire servono almeno $minResponses altri membri del gruppo idonei.';
  }

  @override
  String get answerAnonymously => 'Rispondi in forma anonima';

  @override
  String get groupHealthEligibilityPrivacy =>
      'La tua identità viene usata solo per verificare l\'idoneità e rilasciare una credenziale di risposta. Le risposte inviate non contengono la tua identità di sessione.';

  @override
  String get feedbackEligibilityPrivacy =>
      'La tua identità viene usata per verificare l\'idoneità e rilasciare una credenziale di risposta. L\'invio del feedback non trasmette il token della tua sessione.';

  @override
  String get closingAfterThreshold =>
      'La chiusura diventa disponibile quando viene raggiunta la soglia di privacy.';

  @override
  String get extendResponsePeriod => 'Estendi periodo di risposta';

  @override
  String get deadlinePassedPartialHidden =>
      'La scadenza è passata prima del raggiungimento della soglia di privacy. I risultati parziali restano nascosti.';

  @override
  String get deadlinePassedCreatorAction =>
      'La scadenza è passata prima di ricevere abbastanza risposte. Il creatore può estendere il periodo o terminare senza risultati.';

  @override
  String get viewAggregatedResults => 'Visualizza risultati aggregati';

  @override
  String get closedWithoutResultsMessage =>
      'Questo ciclo è terminato senza risultati perché la soglia di privacy non è stata raggiunta.';

  @override
  String get roundNotAcceptingResponses =>
      'Questo ciclo al momento non accetta risposte.';

  @override
  String get roundLifecycle => 'Ciclo della valutazione';

  @override
  String get responseDeadlineNotSet =>
      'Scadenza delle risposte: non ancora impostata';

  @override
  String responseDeadline(String value) {
    return 'Scadenza delle risposte: $value';
  }

  @override
  String get deadlineReached => 'Scadenza raggiunta';

  @override
  String timeRemainingDays(int days, int hours) {
    return 'Tempo rimanente: ${days}g ${hours}h';
  }

  @override
  String timeRemainingHours(int hours, int minutes) {
    return 'Tempo rimanente: ${hours}h ${minutes}m';
  }

  @override
  String timeRemainingMinutes(int minutes) {
    return 'Tempo rimanente: ${minutes}m';
  }

  @override
  String responsesReceived(int count) {
    return 'Risposte ricevute: $count';
  }

  @override
  String minimumRequired(int count) {
    return 'Minimo richiesto: $count';
  }

  @override
  String get privacyThresholdReached => 'Soglia di privacy raggiunta.';

  @override
  String get privacyThresholdNotReached =>
      'Soglia di privacy non ancora raggiunta.';

  @override
  String get anonymousCountOnly =>
      'Viene mostrato solo il numero di risposte anonime; le identità dei partecipanti non vengono esposte.';

  @override
  String get anonymousGroupAssessment => 'Valutazione anonima del gruppo';

  @override
  String get anonymousFeedback => 'Feedback anonimo';

  @override
  String get feedbackPrivacyNote =>
      'Concentrati sui comportamenti osservabili. Non includere nomi o dettagli identificativi nelle risposte testuali.';

  @override
  String get chooseScore => 'Scegli un punteggio';

  @override
  String get chooseOption => 'Scegli un\'opzione';

  @override
  String get chooseAtLeastOneOption => 'Scegli almeno un\'opzione';

  @override
  String get enterResponse => 'Inserisci una risposta';

  @override
  String unsupportedQuestionType(String kind) {
    return 'Tipo di domanda non supportato: $kind';
  }

  @override
  String get submitPrivately => 'Invia privatamente';

  @override
  String get yourFeedbackRequest => 'La tua richiesta di feedback';

  @override
  String get anonymousFeedbackRequest => 'Richiesta di feedback anonima';

  @override
  String statusValue(String status) {
    return 'Stato: $status';
  }

  @override
  String privacyThresholdResponses(int count) {
    return 'Soglia di privacy: $count risposte';
  }

  @override
  String get creatorCanParticipate =>
      'Hai creato questa valutazione e puoi anche partecipare in forma anonima.';

  @override
  String get eligibleMembersCanParticipate =>
      'I membri idonei del gruppo possono partecipare in forma anonima.';

  @override
  String ratingRange(int min, int max) {
    return 'Valutazione $min-$max';
  }

  @override
  String singleChoiceOptions(int count) {
    return 'Scelta singola · $count opzioni';
  }

  @override
  String multipleChoiceOptions(int count) {
    return 'Scelta multipla · $count opzioni';
  }

  @override
  String get requiredShortText => 'Testo breve obbligatorio';

  @override
  String get optionalShortText => 'Testo breve facoltativo';

  @override
  String get requiredLongText => 'Testo lungo obbligatorio';

  @override
  String get optionalLongText => 'Testo lungo facoltativo';

  @override
  String get informationOnly => 'Solo informativo';

  @override
  String get coreFeedbackName => 'Feedback costruttivo di base';

  @override
  String get coreFeedbackDescription =>
      'Questionario integrato per il feedback costruttivo e il miglioramento personale.';

  @override
  String get coreFeedbackCommunication => 'Comunica in modo chiaro e sincero.';

  @override
  String get coreFeedbackListening =>
      'Ascolta con attenzione e fa sentire gli altri ascoltati.';

  @override
  String get coreFeedbackReliability =>
      'Mantiene gli impegni ed è una persona su cui si può contare.';

  @override
  String get coreFeedbackEmpathy =>
      'Mostra empatia e tiene conto dei sentimenti degli altri.';

  @override
  String get coreFeedbackBoundaries =>
      'Rispetta i confini personali e le differenze.';

  @override
  String get coreFeedbackConflict =>
      'Gestisce i disaccordi senza umiliazioni, minacce o escalation inutili.';

  @override
  String get coreFeedbackSupportiveness =>
      'Offre sostegno senza creare pressione, esclusione o dipendenza malsana.';

  @override
  String get coreFeedbackImprovement =>
      'Qual è una cosa che potrei fare diversamente per migliorare le nostre interazioni? Evita nomi o dettagli identificativi.';

  @override
  String get coreGroupHealthName => 'Salute del gruppo';

  @override
  String get coreGroupHealthDescription =>
      'Questionario anonimo integrato per valutare le dinamiche del gruppo.';

  @override
  String get coreGroupHealthCommunication =>
      'Le persone del gruppo comunicano le cose importanti in modo chiaro e sincero.';

  @override
  String get coreGroupHealthListening =>
      'Le persone si ascoltano e possono esprimere punti di vista diversi.';

  @override
  String get coreGroupHealthSafety =>
      'Le persone possono essere in disaccordo senza derisione, minacce o ritorsioni.';

  @override
  String get coreGroupHealthReliability =>
      'Le persone generalmente rispettano gli impegni presi con il gruppo.';

  @override
  String get coreGroupHealthSupport =>
      'Le persone si aiutano quando è ragionevolmente necessario.';

  @override
  String get coreGroupHealthConflict =>
      'I problemi e i disaccordi vengono gestiti in modo costruttivo.';

  @override
  String get coreGroupHealthBoundaries =>
      'I confini personali e le differenze vengono rispettati.';

  @override
  String get coreGroupHealthImprovement =>
      'Qual è una cosa che questo gruppo potrebbe migliorare? Evita nomi o dettagli identificativi.';

  @override
  String get aggregatedResults => 'Risultati aggregati';

  @override
  String get resultsNotAvailable => 'I risultati non sono disponibili';

  @override
  String responseCount(int count) {
    return '$count risposte';
  }

  @override
  String get aggregatedResultsPrivacy =>
      'I risultati vengono mostrati solo in forma aggregata dopo il raggiungimento della soglia di privacy.';

  @override
  String get noAnswers => 'Nessuna risposta';

  @override
  String averageValue(String value) {
    return 'Media $value';
  }

  @override
  String get noCommentsSubmitted => 'Nessun commento inviato.';

  @override
  String get historyUnavailable => 'La cronologia non è disponibile';

  @override
  String get noHistoryYet => 'Nessuna cronologia ancora';

  @override
  String get noHistoryMessage =>
      'Completa una valutazione della salute del gruppo per iniziare a costruire una cronologia.';

  @override
  String get groupHealthHistoryExplanation =>
      'Ogni voce rappresenta le risposte aggregate di una valutazione chiusa che ha raggiunto la soglia di privacy. Le variazioni possono riflettere sia le percezioni sia i cambiamenti nella composizione del gruppo. Non viene calcolato alcun punteggio complessivo di salute.';

  @override
  String aggregatedResponseCount(int count) {
    return '$count risposte aggregate';
  }

  @override
  String get noChange => 'Nessuna variazione';

  @override
  String versusPrevious(String value) {
    return '$value rispetto alla precedente';
  }

  @override
  String get playfulReflection => 'Riflessione giocosa';

  @override
  String get playfulDisclaimer =>
      'Un riepilogo giocoso del feedback aggregato — non una valutazione della personalità.';

  @override
  String get thoughtfulOwl => 'Gufo riflessivo';

  @override
  String get helpingOctopus => 'Polpo disponibile';

  @override
  String get clearSignalFox => 'Volpe dalla comunicazione chiara';

  @override
  String get steadyTurtle => 'Tartaruga affidabile';

  @override
  String get respectfulHedgehog => 'Riccio rispettoso';

  @override
  String get calmElephant => 'Elefante calmo';

  @override
  String get balancedCapybara => 'Capibara equilibrato';

  @override
  String get balancedPlayfulMessage =>
      'I segnali più forti sono molto vicini tra loro, quindi in questo ciclo non emerge una dimensione chiaramente dominante.';

  @override
  String personalPlayfulMessage(String prompt, String average) {
    return 'Il tuo segnale aggregato più forte è stato \"$prompt\" ($average/5).';
  }

  @override
  String groupPlayfulMessage(String prompt, String average) {
    return 'Il segnale aggregato più forte del gruppo è stato \"$prompt\" ($average/5).';
  }

  @override
  String get newQuestionnaire => 'Nuovo questionario';

  @override
  String get questionnairePrivacyNote =>
      'Nota sulla privacy: non chiedere nomi, iniziali, indirizzi, date di nascita o altre informazioni identificative. L\'archiviazione anonima non può impedire a una persona di identificarsi volontariamente in una risposta.';

  @override
  String get somethingWentWrong => 'Si è verificato un problema.';

  @override
  String get couldNotSaveQuestionnaire =>
      'Impossibile salvare il questionario.';

  @override
  String get builtIn => 'Integrato';

  @override
  String get statusPublished => 'Pubblicato';

  @override
  String versionBlocks(int version, int count) {
    return 'Versione $version · $count blocchi';
  }

  @override
  String get view => 'Visualizza';

  @override
  String get editDraft => 'Modifica bozza';

  @override
  String get publish => 'Pubblica';

  @override
  String get newVersion => 'Nuova versione';

  @override
  String get editorPrivacyNote =>
      'Evita domande che richiedono informazioni identificative. Preferisci comportamenti osservabili e scelte limitate rispetto a testo libero che possa identificare una persona.';

  @override
  String get questionnaireTitle => 'Titolo del questionario';

  @override
  String get questionnaireTitleExample =>
      'Esempio: Comunicazione e collaborazione del team';

  @override
  String get enterTitle => 'Inserisci un titolo';

  @override
  String get descriptionInstructionsOptional =>
      'Descrizione / istruzioni (facoltative)';

  @override
  String get descriptionExample =>
      'Esempio: Pensa a come abbiamo lavorato insieme nell\'ultimo mese.';

  @override
  String get addBlock => 'Aggiungi blocco';

  @override
  String get saveDraft => 'Salva bozza';

  @override
  String blockNumber(int number) {
    return 'Blocco $number';
  }

  @override
  String get type => 'Tipo';

  @override
  String get ratingScale => 'Scala di valutazione';

  @override
  String get singleChoice => 'Scelta singola';

  @override
  String get multipleChoice => 'Scelta multipla';

  @override
  String get shortText => 'Testo breve';

  @override
  String get longText => 'Testo lungo';

  @override
  String get descriptionInformation => 'Descrizione / informazione';

  @override
  String get scaleHelper =>
      'Scala di valutazione: utile per aspetti misurabili, ad esempio la chiarezza della comunicazione.';

  @override
  String get singleChoiceHelper =>
      'Scelta singola: la persona seleziona esattamente un\'opzione.';

  @override
  String get multipleChoiceHelper =>
      'Scelta multipla: la persona può selezionare più opzioni.';

  @override
  String get shortTextHelper =>
      'Testo breve: ideale per un\'osservazione o un suggerimento conciso.';

  @override
  String get longTextHelper =>
      'Testo lungo: usalo quando è utile una risposta costruttiva più dettagliata.';

  @override
  String get descriptionHelper =>
      'Solo informativo: viene mostrato ai partecipanti e non raccoglie una risposta.';

  @override
  String get informationText => 'Testo informativo';

  @override
  String get question => 'Domanda';

  @override
  String get informationTextExample =>
      'Esempio: Leggi questo testo prima di rispondere alle domande successive.';

  @override
  String get questionBehaviorHelper =>
      'Mantieni la domanda sui comportamenti osservabili, non sulla personalità o sull\'identità.';

  @override
  String get blockCannotBeBlank => 'Questo blocco non può essere vuoto';

  @override
  String get required => 'Obbligatorio';

  @override
  String get minimum => 'Minimo';

  @override
  String get maximum => 'Massimo';

  @override
  String get maxMustExceedMin => 'Il massimo deve essere maggiore del minimo';

  @override
  String get optionsOnePerLine => 'Opzioni (una per riga)';

  @override
  String get optionsExample => 'Esempio: Raramente\nA volte\nSpesso';

  @override
  String get addAtLeastTwoOptions => 'Aggiungi almeno due opzioni';

  @override
  String get optionOne => 'Opzione 1';

  @override
  String get optionTwo => 'Opzione 2';

  @override
  String get groupRoleOwner => 'Proprietario';

  @override
  String get groupRoleMember => 'Membro';

  @override
  String get chooseQuestionnaire => 'Scegli questionario';

  @override
  String get noPublishedQuestionnaires =>
      'Non sono disponibili questionari pubblicati.';

  @override
  String get somethingWentWrongTryAgain =>
      'Si è verificato un problema. Riprova.';
}
