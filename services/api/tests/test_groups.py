from fastapi.testclient import TestClient


def _create_user(client: TestClient) -> dict[str, str]:
    response = client.post("/api/v1/users/session")
    assert response.status_code == 201
    return response.json()


def _auth(session: dict[str, str]) -> dict[str, str]:
    return {"Authorization": f"Bearer {session['sessionToken']}"}


def test_create_group_and_list_memberships(client: TestClient) -> None:
    user = _create_user(client)

    response = client.post(
        "/api/v1/groups",
        headers=_auth(user),
        json={"name": "  Close   Friends  "},
    )

    assert response.status_code == 201
    group = response.json()
    assert group["name"] == "Close Friends"
    assert group["role"] == "owner"
    assert group["joinCode"]

    list_response = client.get("/api/v1/groups", headers=_auth(user))
    assert list_response.status_code == 200
    groups = list_response.json()
    assert len(groups) == 1
    assert groups[0]["id"] == group["id"]
    assert groups[0]["role"] == "owner"
    assert "joinCode" not in groups[0]


def test_second_user_can_join_group(client: TestClient) -> None:
    owner = _create_user(client)
    member = _create_user(client)

    created = client.post(
        "/api/v1/groups",
        headers=_auth(owner),
        json={"name": "Friends"},
    ).json()

    join_response = client.post(
        "/api/v1/groups/join",
        headers=_auth(member),
        json={"joinCode": created["joinCode"]},
    )

    assert join_response.status_code == 200
    joined = join_response.json()
    assert joined["id"] == created["id"]
    assert joined["role"] == "member"

    member_groups = client.get("/api/v1/groups", headers=_auth(member)).json()
    assert member_groups == [joined]


def test_join_is_idempotent(client: TestClient) -> None:
    owner = _create_user(client)
    created = client.post("/api/v1/groups", headers=_auth(owner), json={"name": "Friends"}).json()

    response = client.post(
        "/api/v1/groups/join",
        headers=_auth(owner),
        json={"joinCode": created["joinCode"]},
    )

    assert response.status_code == 200
    assert response.json()["role"] == "owner"


def test_invalid_join_code_is_not_accepted(client: TestClient) -> None:
    user = _create_user(client)
    response = client.post(
        "/api/v1/groups/join",
        headers=_auth(user),
        json={"joinCode": "not-a-real-code"},
    )

    assert response.status_code == 404
    assert response.json()["detail"] == "Invalid join code"


def test_non_member_cannot_fetch_group(client: TestClient) -> None:
    owner = _create_user(client)
    outsider = _create_user(client)
    group = client.post("/api/v1/groups", headers=_auth(owner), json={"name": "Friends"}).json()

    response = client.get(f"/api/v1/groups/{group['id']}", headers=_auth(outsider))

    assert response.status_code == 404
    assert response.json()["detail"] == "Group not found"


def test_member_can_fetch_group(client: TestClient) -> None:
    owner = _create_user(client)
    group = client.post("/api/v1/groups", headers=_auth(owner), json={"name": "Friends"}).json()

    response = client.get(f"/api/v1/groups/{group['id']}", headers=_auth(owner))

    assert response.status_code == 200
    assert response.json()["id"] == group["id"]
    assert response.json()["role"] == "owner"


def test_group_name_cannot_be_only_whitespace(client: TestClient) -> None:
    user = _create_user(client)
    response = client.post(
        "/api/v1/groups",
        headers=_auth(user),
        json={"name": "   "},
    )

    assert response.status_code == 422
