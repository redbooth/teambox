//
// Utility methods for Teambox API
//
(function () {

  function hasSameIdAndType(id, type) {
    return function (el) {
      return ((el.id === id) && (el.type === type));
    };
  }

  /**
   * Parses a Teambox API response object and modifies it, fetching each
   * reference object from the response.
   * Returns an array of objects with their referenced projects, comments, etc.
   *
   * @param {Object} json
   * @return {Array}
   */
  _.parseFromAPI = function (json) {

    /**
     * Load a utility method to find a reference object by id and type
     *
     * @param {Integer} id
     * @param {String} type
     */
    function findRef(id, type) {
      if (id && type) {
        return _(json.references).detect(hasSameIdAndType(id, type));
      }
    }

    /**
     * Fetches any referenced objects as part of each object.
     *
     * Example: If task.project_id is defined, it will find that project
     * within the references and load it as task.project
     *
     * @param {Object} e
     */
    function fetchReferences(e) {

      // Find elements if they are referenced
      e.user = findRef(e.user_id, 'User');
      e.project = findRef(e.project_id, 'Project');
      e.task_list = findRef(e.task_list_id, 'TaskList');
      e.page = findRef(e.page_id, 'Page');
      e.assigned = findRef(e.assigned_id, 'Person');
      e.organization = findRef(e.organization_id, 'Organization');

      // Only 'new' and 'open' tasks have due dates and assignees
      // FIXME this is not true, we keep the assigned and date for tasks
      // on hold but we just don't show it in the pending task lists
      if (e.type === 'Task' && e.status && e.status !== 0 && e.status !== 1) {
        e.due_on = undefined;
        e.assigned = undefined;
      }

      // Give titles to untitled conversations
      if (e.type === 'Conversation' && e.simple) {
        e.name = 'Untitled';
      }

      // Fetch first_comment and recent_comments for thread elements
      if (e.first_comment_id) {
        e.first_comment = findRef(e.first_comment_id, "Comment");
      }

      if (e.recent_comment_ids) {
        e.recent_comments = _(e.recent_comment_ids).chain()
          .map(function (id) {
            var comment = findRef(id, "Comment");
            return comment;
          })
          .compact() // In case there are no recent comments in references
          .sortBy(function (c) {
            return c.id;
          })
          .value();
        e.hidden_comments_count = _([e.comments_count - e.recent_comments.length, 0]).max();
        e.last_comment = _(e.recent_comments).last();
      }

      if (e.target_id) {
        e.target = findRef(e.target_id, e.target_type);

        if (e.target) {
          e.target.target = findRef(e.target.target_id, e.target.target_type);
        }
      }

      if (e.type === 'Comment') {
        if (e.upload_ids && e.upload_ids.length) {
          e.uploads = _(e.upload_ids).chain()
            .map(function (id) {
              return findRef(id, 'Upload');
            })
            .compact()
            .sortBy(function (c) {
              return c.id;
            })
            .value();
        }

        if (e.google_doc_ids && e.google_doc_ids.length) {
          e.google_docs = _(e.google_doc_ids).chain()
            .map(function (id) {
              return findRef(id, 'GoogleDoc');
            })
            .compact()
            .sortBy(function (c) {
              return c.id;
            })
            .value();
        }
      }

      return e;
    }

    // Fetch targets and targets of targets from reference objects
    if (json.references) {
      _(json.references).each(fetchReferences);
    }

    // Fetch targets and targets of targets from Activities
    if (json.objects) {
      _(json.objects).each(fetchReferences);
    } else {
      fetchReferences(json);
    }

    return json.objects ? json.objects : json;
  };

  /**
   * Find an element by id and type inside a Backbone collection
   *
   * @param {Object} collection
   * @param {Integer} id
   * @param {String} type
   */
  _.findFromCollection = function (collection, id, type) {
    return collection.getAttributes().detect(hasSameIdAndType(id, type));
  };

}());
