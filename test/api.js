module.exports = {
  "[GET]/api/users": {
    name: "wtf"
  },
  "[POST, PUT]/api/users": {
    name: "wtf"
  },
  "[GET]/api/user/:id": function(url, method, params) {
    return {
      id: params.id
    };
  },
  "[GET]/api/user/special": {
    id: "special"
  },
  "[ALL]/api/all_methods": 1
}
