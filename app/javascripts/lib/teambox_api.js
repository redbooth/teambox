// 
// Utility methods for Teambox API
//


// Parses a Teambox API response object and modifies it, fetching each
// reference object from the response.
// Returns an array of objects with their referenced projects, comments, etc.
_.parseFromAPI = function(json) {

  // Fetches any referenced objects as part of each object.
  // Example: If task.project_id is defined, it will find that project
  // within the references and load it as task.project
  fetchReferences = function(collection, e) {

    // Load a utility method to find a reference object by id and type
    collection.findRef = function (id, type) {
      return _(this.references).detect(function(i) { 
        return ((i.id == id) && (i.type == type));
      });
    };

    // Find elements if they are referenced
    e.user = collection.findRef(e.user_id, 'User');
    e.project = collection.findRef(e.project_id, 'Project');
    e.task_list = collection.findRef(e.task_list_id, 'TaskList');
    e.page = collection.findRef(e.page_id, 'Page');
    e.assigned = collection.findRef(e.assigned_id, 'Person');
    e.organization = collection.findRef(e.organization_id, 'Organization');

    // Insert a method to generate URLs for this item
    e.url = function() {
      switch(this.type) {
        case "Comment":
          return this.target.url();
        case "Conversation":
          return "#!/projects/"+this.project.permalink+"/conversations/"+this.id;
        case "Task":
          return "#!/projects/"+this.project.permalink+"/tasks/"+this.id;
        case "TaskList":
          return "#!/projects/"+this.project.permalink+"/task_lists/"+this.id;
        case "Page":
          return "#!/projects/"+this.project.permalink+"/pages/"+this.id;
        case "Project":
          return "#!/projects/"+this.permalink;
        case "User":
          return "#!/users/"+this.username;
        default:
          console.log("Didn't implement URL for "+this.type+". Object: "+this);
          return "#!/wip";
      }
    };

    // Only 'new' and 'open' tasks have due dates and assignees
    if(e.type == "Task" && e.status && e.status !== 0 && e.status !== 1) {
      e.due_on = undefined;
      e.assigned = undefined;
    }

    // Give titles to untitled conversations
    if(e.type == "Conversation" && e.simple) {
      e.name = "Untitled";
    }

    // Fetch first_comment and recent_comments for thread elements
    if (e.first_comment_id) {
      e.first_comment = collection.findRef(e.first_comment_id, "Comment");
    }
    if (e.recent_comment_ids) {
      e.recent_comments = _(e.recent_comment_ids).chain()
        .map(function(id) { return collection.findRef(id, "Comment"); })
        .compact() // In case there are no recent comments in references
        .sortBy(function(c) { return c.id; })
        .reject(function(c) { return c.id == e.first_comment_id; })
        .value();
      e.hidden_comments_count = _([e.comments_count - 1 - e.recent_comments.length, 0]).max();
      e.last_comment = _(e.recent_comments).last();
    }
    if (e.target_id) {
      e.target = collection.findRef(e.target_id, e.target_type);
      if (e.target) {
        e.target.target = collection.findRef(e.target.target_id, e.target.target_type);
      }
    }
    return e;
  };

  // Fetch targets and targets of targets from reference objects
  _(json.references).each(function(r) {
    fetchReferences(json, r);
  });

  // Fetch targets and targets of targets from Activities
  _(json.objects).each(function(o) {
    fetchReferences(json, o);
  });

  return json.objects;
};
