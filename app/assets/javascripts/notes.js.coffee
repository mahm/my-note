App = new Ext.Application
  name: 'NotesApp'
  useLoadMask: true
  launch: ->
    Ext.regModel 'Note'
      idProperty: 'id'
      fields: [
        {name: 'id', type: 'int'},
        {name: 'date', type: 'date', dateFormat: 'c'},
        {name: 'title', type: 'string'},
        {name: 'narrative', type: 'string'}
      ],
      validations: [
        {type: 'presence', field: 'id'},
        {type: 'presence', field: 'title', message: 'Please enter a title for this note.'}
      ]

    Ext.regStore 'NotesStore',
      model: 'Note'
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

    NotesApp.views.noteEditorTopToolbar = new Ext.Toolbar
      title: 'Edit Note'
      layout: 'hbox'
      items: [
        {
          text: 'Home'
          ui: 'back'
          handler: ->
            NotesApp.views.viewport.setActiveItem('notesListContainer', {type: 'slide', direction: 'right'})
        },
        { xtype: 'spacer' },
        {
          text: 'Save'
          ui: 'action'
          handler: ->
            noteEditor = NotesApp.views.noteEditor
            currentNote = noteEditor.getRecord()
            noteEditor.updateRecord(currentNote)
            errors = currentNote.validate()
            if !errors.isValid()
              currentNote.reject()
              Ext.Msg.alert('Wait!', errors.getByField('title')[0].message, Ext.emptyFn)
              return
            notesList = NotesApp.views.notesList
            notesStore = notesList.getStore()
            if notesStore.findRecord('id', currentNote.data.id) == null
              notesStore.add(currentNote)
            else
              currentNote.setDirty()
            notesStore.sync()
            notesStore.sort([{property: 'date', direction: 'DESC'}])
            notesList.refresh()
            NotesApp.views.viewport.setActiveItem('notesListContainer', {type: 'slide', direction: 'right'})
        }
      ]

    NotesApp.views.noteEditorBottomToolbar = new Ext.Toolbar
      dock: 'bottom'
      items: [
        { xtype: 'spacer' },
        {
          iconCls: 'trash'
          iconMask: true
          handler: ->
            currentNote = NotesApp.views.noteEditor.getRecord()
            notesList = NotesApp.views.notesList
            notesStore = notesList.getStore()
            if notesStore.findRecord('id', currentNote.data.id)
              notesStore.remove(currentNote)
            notesStore.sync()
            notesList.refresh()
            NotesApp.views.viewport.setActiveItem('notesListContainer', {type: 'slide', direction: 'right'})
        }
      ]

    NotesApp.views.noteEditor = new Ext.form.FormPanel
      id: 'noteEditor'
      dockedItems: [
        NotesApp.views.noteEditorTopToolbar,
        NotesApp.views.noteEditorBottomToolbar
      ]
      items: [
        {
          xtype: 'textfield'
          name: 'title'
          label: 'Title'
          required: true
        },
        {
          xtype: 'textareafield'
          name: 'narrative'
          label: 'Narrative'
        }
      ]

    NotesApp.views.notesList = new Ext.List
      id: 'notesList'
      store: 'NotesStore'
      grouped: true
      emptyText: '<div style="margin:5px;">No notes cached.</div>'
      itemTpl: '<div class="list-item-title">{title}</div><div class="list-item-narrative">{narrative}</div>'
      onItemDisclosure: (record) ->
        selectedNote = record
        NotesApp.views.noteEditor.load(selectedNote)
        NotesApp.views.viewport.setActiveItem('noteEditor', {type: 'slide', direction: 'left'})
      listeners:
        'render': (thisComponent) ->
          thisComponent.getStore().load()

    NotesApp.views.notesListToolbar = new Ext.Toolbar
      id: 'notesListToolbar'
      title: 'My Notes'
      layout: 'hbox'
      items: [
        {xtype: 'spacer'},
        {
          id: 'newNoteButton'
          text: 'New'
          ui: 'action'
          handler: ->
            now = new Date()
            noteId = now.getTime()
            note = Ext.ModelMgr.create(
              {
                id: noteId
                date: now
                title: ''
                narrative: ''
              }, 'Note'
            )
            NotesApp.views.noteEditor.load(note)
            NotesApp.views.viewport.setActiveItem('noteEditor', {type: 'slide', direction: 'left'})
        }
      ]

    NotesApp.views.notesListContainer = new Ext.Panel
      id: 'notesListContainer'
      layout: 'fit'
      html: 'This is the notes list container'
      dockedItems: [NotesApp.views.notesListToolbar]
      items: [NotesApp.views.notesList]

    NotesApp.views.viewport = new Ext.Panel
      fullscreen: true
      layout: 'card'
      cardAnimation: 'slide'
      items: [
        NotesApp.views.notesListContainer,
        NotesApp.views.noteEditor
      ]
