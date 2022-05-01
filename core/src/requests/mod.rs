use crate::core::Core;
use crate::core_proto::*;

pub async fn handle_sleep(req: SleepRequest) -> Box<SleepResponse> {
    tokio::time::sleep(tokio::time::Duration::from_millis(req.millis)).await;

    let response = SleepResponse {
        text: format!("awake after {} milliseconds", req.millis),
        ..Default::default()
    };

    return Box::new(response);
}

pub fn handle_greeting(req: GreetingRequest) -> Box<GreetingResponse> {
    let response = GreetingResponse {
        text: format!("{}, {}!", req.verb, req.name),
        ..Default::default()
    };

    return Box::new(response);
}

pub fn handle_backtrace(_req: BacktraceRequest) -> Box<BacktraceResponse> {
    let bt = backtrace::Backtrace::new();

    let response = BacktraceResponse {
        text: format!("{:?}", bt),
        ..Default::default()
    };

    return Box::new(response);
}