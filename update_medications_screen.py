with open('lib/features/medications/presentation/screens/medications_screen.dart', 'r') as f:
    content = f.read()

content = content.replace('controller.adherenceState.isLoading', 'controller.state.isAdherenceLoading')
content = content.replace('controller.adherenceState.data', 'controller.state.adherence')
content = content.replace('controller.selectedTabIndex', 'controller.state.selectedTabIndex')
content = content.replace('controller.countsState.data?.morning', 'controller.state.counts?.morning')
content = content.replace('controller.countsState.data?.afternoon', 'controller.state.counts?.afternoon')
content = content.replace('controller.countsState.data?.evening', 'controller.state.counts?.evening')

# _buildMedicationList replacements
content = content.replace(
    'if (controller.medicationsState.isLoading) {',
    '''final section = controller.state.selectedTabIndex == 0 ? 'MORNING' : controller.state.selectedTabIndex == 1 ? 'AFTERNOON' : 'EVENING';
    if (controller.state.sectionLoadingStatus[section] == true) {'''
)

content = content.replace(
    'if (controller.medicationsState.error != null) {',
    'if (controller.state.sectionErrors[section] != null) {'
)

content = content.replace(
    'controller.medicationsState.error!',
    'controller.state.sectionErrors[section]!'
)

content = content.replace(
    'final meds = controller.medicationsState.data ?? [];',
    'final meds = controller.state.medicationsBySection[section] ?? [];'
)

content = content.replace(
    'controller.confirmingMedicationId == med.id',
    'controller.state.confirmingMedicationId == med.id'
)

with open('lib/features/medications/presentation/screens/medications_screen.dart', 'w') as f:
    f.write(content)
