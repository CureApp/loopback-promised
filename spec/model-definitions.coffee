module.exports =
    author:
        aclType: 'none'
        name: 'author'
        plural: 'authors'
        base: 'User'
        idInjection: true
        properties: {}
        validations: []
        relations:
            notebooks:
                type: 'hasMany'
                model: 'notebook'
                foreignKey: ''
        acls: []
        methods: []

    leaf:
        aclType: 'none'
        name: 'leaf'
        plural: 'leaves'
        base: 'PersistedModel'
        idInjection: true
        properties:
            content:
                type: 'string'
            createdAt:
                type: 'date'
        validations: []
        relations: {}
        acls: []
        methods: []


    notebook:
        aclType: 'none'
        name: 'notebook'
        plural: 'notebooks'
        base: 'PersistedModel'
        idInjection: true
        properties:
            name:
                type: 'string'
                required: true
        validations: []
        relations:
            leaves:
                type: 'hasMany'
                model: 'leaf'
                foreignKey: ''
        acls: []
        methods: []

