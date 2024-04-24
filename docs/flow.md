
```mermaid
graph TD

UI -- "event" --> HSAppBloc
HSAppBloc -- "state" --> UI
HSAppBloc --"requst" --> HSAuthenticationRepository
HSAuthenticationRepository -- "response" --> HSAppBloc
HSAuthenticationRepository --> HSUserModel
```
