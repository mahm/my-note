Ext.regStore 'NotesStore',
  model: 'NoteModel'

  sorters: [
    property: 'date'
    direction: 'DESC'
  ]

  proxy:
    type: 'localstorage'
    id: 'notes-app-localstore'

  getGroupString: (record) ->
    if record && record.data.date
      return record.get('date').toDateString()
    else
      return ''

  data: [
    {id: 1, date: new Date(), title: 'Test Note', narrative: 'This is simply a test note'}
  ]

NotesApp.stores.notesStore = Ext.StoreMgr.get('NotesStore')
